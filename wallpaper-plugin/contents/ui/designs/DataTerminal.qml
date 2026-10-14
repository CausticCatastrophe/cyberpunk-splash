import QtQuick
import ".."

// Identity block and a log of live readings on the left, hex columns down the
// right edge, clock on top, title in the middle.
// Each reading has its own line and a sparkline of its recent history. CPU lines
// use the accent color and sit in the left column; GPU lines use the secondary
// color and sit in the right column.
// The log shows real readings: live ones (cpu, memory, temperatures, gpu, uptime)
// when the wallpaper is running on a screen, and static facts in a still image.
// Nothing identifying is shown: no user names, addresses, processes or files.
// Motion budget (about 3 frames a second, close to free): the cursor blinks twice
// a second, one hex row steps once a second, readings and sparklines update every
// few seconds, and the clock redraws once a minute.
Base {
    id: root

    SystemInfo { id: sys }

    // false for the still images baked for the login screen
    property bool liveStats: true

    // log settings; the wallpaper plugin overrides these per screen
    property string logItems: sys.logItems
    property int logRefresh: sys.logRefresh
    property int sparkStep: sys.sparkStep
    property int sparkPoints: sys.sparkPoints

    property bool cursorOn: true
    property int hot: 0      // highlighted hex row

    // sparkline history, as fractions 0..1 per reading; how many points it keeps
    // and how often one is recorded come from the config
    readonly property int histLen: sparkPoints
    property var hist: ({})
    property int histTick: 0

    Loader {
        id: live
        active: root.liveStats
        source: "LiveStats.qml"
    }
    Binding {
        target: live.item
        property: "interval"
        value: root.logRefresh * 1000
        when: live.status === Loader.Ready
    }

    // ---- formatting helpers ----
    function pad(label, value) {
        var dots = Math.max(2, 10 - label.length);
        return label + " " + new Array(dots + 1).join(".") + " " + value;
    }
    function gib(bytes) { return (bytes / 1073741824).toFixed(1); }
    function pct(v) { return Math.round(v) + "%"; }
    function deg(v) { return Math.round(v) + " C"; }
    function clamp(f) { return Math.max(0, Math.min(1, f)); }
    function uptimeText(s) {
        var d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60);
        return d > 0 ? d + "d " + h + "h" : (h > 0 ? h + "h " + m + "m" : m + "m");
    }
    function usedOf(used, total) { return gib(used) + " / " + gib(total) + " GiB"; }

    // One log line. c is the color group ("a" accent, "s" secondary); key and f
    // feed the sparkline (key is empty for lines without one).
    function line(label, value, c, key, f) {
        return { t: pad(label, value), c: c, key: key, f: f, y: 0 };
    }

    // The line for an item name, or null when it has no value to show.
    function entry(name) {
        var L = live.item;
        switch (name) {
        case "cpu":
            return L && isFinite(L.cpu) ? line("cpu", pct(L.cpu), "a", "cpu", clamp(L.cpu / 100)) : null;
        case "cputemp":
            return L && isFinite(L.temp) && L.temp > 0 ? line("cpu temp", deg(L.temp), "a", "cputemp", clamp((L.temp - 25) / 70)) : null;
        case "mem":
            return L && L.memTotal > 0 ? line("memory", usedOf(L.memUsed, L.memTotal), "a", "mem", clamp(L.memUsed / L.memTotal)) : null;
        case "gpu":
            return L && isFinite(L.gpu) ? line("gpu", pct(L.gpu), "s", "gpu", clamp(L.gpu / 100)) : null;
        case "gputemp":
            return L && isFinite(L.gpuTemp) && L.gpuTemp > 0 ? line("gpu temp", deg(L.gpuTemp), "s", "gputemp", clamp((L.gpuTemp - 25) / 70)) : null;
        case "vram":
            return L && L.vramTotal > 0 ? line("vram", usedOf(L.vramUsed, L.vramTotal), "s", "vram", clamp(L.vramUsed / L.vramTotal)) : null;
        case "uptime":  return L && L.uptime > 0 ? line("uptime", uptimeText(L.uptime), "a", "", 0) : null;
        case "os":      return sys.osName !== "" ? line("os", sys.osName, "a", "", 0) : null;
        case "kernel":  return sys.kernel !== "" ? line("kernel", sys.kernel, "a", "", 0) : null;
        case "plasma":  return sys.plasma !== "" ? line("plasma", sys.plasma, "a", "", 0) : null;
        case "qt":      return sys.qt !== "" ? line("qt", sys.qt, "a", "", 0) : null;
        case "host":    return sys.hostname !== "" ? line("host", sys.hostname, "a", "", 0) : null;
        }
        return null;
    }

    readonly property real lineH: u * 1.9
    readonly property real colW: u * 37      // width of one log column

    // Lines are split into two columns by color group: accent lines (cpu, cputemp,
    // mem, uptime and the static facts) on the left, secondary lines (gpu, gputemp,
    // vram) on the right. That keeps the log short, so it stays clear of the title.
    readonly property var lines: {
        var out = [], names = root.logItems.split(","), left = 0, right = 0;
        for (var i = 0; i < names.length && out.length < 12; i++) {
            var t = entry(names[i].trim());
            if (t === null) continue;
            if (t.c === "s") { t.col = 1; t.row = right++; }
            else             { t.col = 0; t.row = left++; }
            out.push(t);
        }
        if (out.length === 0) {     // a still image with only live items listed
            var fb = [entry("plasma"), entry("qt")];
            for (var j = 0; j < fb.length; j++) {
                if (fb[j] === null) continue;
                fb[j].col = 0; fb[j].row = left++;
                out.push(fb[j]);
            }
        }
        return out;
    }
    function rowsIn(col) {
        var n = 0;
        for (var i = 0; i < lines.length; i++) if (lines[i].col === col) n++;
        return n;
    }
    readonly property int rowsLeft: rowsIn(0)
    readonly property int rowsRight: rowsIn(1)
    readonly property bool twoCols: rowsRight > 0
    // tall enough for the longer column plus the cursor row under the left one
    readonly property real logH: (Math.max(rowsLeft + 1, rowsRight)) * lineH

    // record one point per sparkline every sparkStep seconds
    function sample() {
        var h = hist, L = lines;
        for (var i = 0; i < L.length; i++) {
            var k = L[i].key;
            if (k === "" || !isFinite(L[i].f)) continue;
            var a = h[k] || [];
            a.push(L[i].f);
            while (a.length > histLen) a.shift();
            h[k] = a;
        }
        histTick++;
    }
    Timer {
        interval: root.sparkStep * 1000
        repeat: true
        running: root.liveStats
        triggeredOnStart: true
        onTriggered: root.sample()
    }

    // session type, read from Qt; hidden when it is not a real display platform
    readonly property string session: {
        var p = Qt.platform.pluginName;
        if (p.indexOf("wayland") === 0) return "WAYLAND";
        if (p === "xcb") return "X11";
        return "";
    }

    // deterministic pseudo-random hex so the picture is stable between runs
    function hex(seed, n) {
        var s = seed, out = "";
        for (var i = 0; i < n; i++) {
            s = (s * 1103515245 + 12345) & 0x7fffffff;
            out += "0123456789ABCDEF".charAt((s >> 16) & 15);
        }
        return out;
    }
    readonly property int rows: 34
    readonly property real rowH: usableH * 0.9 / rows

    // ---- hex columns, right edge ----
    component HexColumn: Item {
        id: col
        property int seed: 1
        property real fade: 1
        width: root.u * 8
        height: root.height
        Repeater {
            model: root.rows
            Text {
                required property int index
                y: root.usableH * 0.05 + index * root.rowH
                text: root.hex(col.seed * 131 + index * 17, 4) + " " + root.hex(col.seed * 7 + index * 31, 4)
                color: index === root.hot ? root.secondary : root.accent
                opacity: (index === root.hot ? 0.95 : 0.30) * col.fade
                font.family: root.monoFont
                font.pixelSize: root.rowH * 0.62
                font.letterSpacing: root.u * 0.08
            }
        }
    }
    // kept clear of the title, which reaches out to about 80% of the width
    HexColumn { x: root.width - root.u * 10; seed: 12; fade: 1.0 }
    HexColumn { x: root.width - root.u * 18; seed: 14; fade: 0.6 }

    // ---- identity block, top left ----
    Column {
        x: root.u * 5
        y: root.u * 6
        spacing: root.u * 0.5
        Repeater {
            model: [["HOST", sys.hostname], ["OS", sys.osName], ["KERNEL", sys.kernel], ["SESSION", root.session]]
            Row {
                required property var modelData
                visible: modelData[1] !== ""
                spacing: root.u * 1.2
                Text {
                    width: root.u * 6
                    text: modelData[0]
                    color: root.accent; opacity: 0.55
                    font.family: root.monoFont
                    font.pixelSize: root.u * 0.95
                    font.letterSpacing: root.u * 0.12
                }
                Text {
                    text: modelData[1].toUpperCase()
                    color: "#e8e6d9"; opacity: 0.8
                    font.family: root.monoFont
                    font.pixelSize: root.u * 0.95
                    font.letterSpacing: root.u * 0.12
                }
            }
        }
    }

    // ---- log with sparklines, bottom left ----
    Item {
        id: logBlock
        x: root.u * 5
        y: root.height - root.insetPx - root.u * 4 - root.logH
        width: (root.twoCols ? 2 : 1) * root.colW
        height: root.logH

        Rectangle { width: 2; height: (root.rowsLeft + 1) * root.lineH; color: root.accent; opacity: 0.8 }
        Rectangle {
            visible: root.twoCols
            x: root.colW
            width: 2; height: root.rowsRight * root.lineH
            color: root.secondary; opacity: 0.8
        }

        Repeater {
            model: root.lines
            Item {
                id: row
                required property var modelData
                readonly property color tint: modelData.c === "s" ? root.secondary : root.accent
                y: modelData.row * root.lineH
                x: modelData.col * root.colW + root.u * 1.4
                width: root.colW - root.u * 1.4
                height: root.lineH

                // the whole line takes its group color: accent for CPU, secondary for GPU
                Text {
                    color: row.tint
                    opacity: 0.92
                    font.family: root.monoFont
                    font.pixelSize: root.u * 1.15
                    text: "> " + modelData.t
                }

                // history of this reading, newest on the right
                Canvas {
                    id: spark
                    visible: row.modelData.key !== ""
                    x: root.u * 18
                    y: root.u * 0.15
                    width: root.u * 11
                    height: root.u * 1.3
                    readonly property int tick: root.histTick
                    onTickChanged: requestPaint()
                    onPaint: {
                        var c = getContext("2d");
                        c.reset();
                        c.strokeStyle = row.tint;
                        c.fillStyle = row.tint;
                        c.globalAlpha = 0.25;
                        c.lineWidth = 1;
                        c.beginPath(); c.moveTo(0, height - 0.5); c.lineTo(width, height - 0.5); c.stroke();
                        var a = root.hist[row.modelData.key] || [];
                        if (a.length < 2) return;
                        var step = width / (root.histLen - 1), x0 = width - (a.length - 1) * step;
                        c.beginPath();
                        for (var i = 0; i < a.length; i++) {
                            var x = x0 + i * step, y = height - 1.5 - a[i] * (height - 3);
                            if (i === 0) c.moveTo(x, y); else c.lineTo(x, y);
                        }
                        c.lineTo(width, height - 0.5);
                        c.lineTo(x0, height - 0.5);
                        c.closePath();
                        c.globalAlpha = 0.14;
                        c.fill();
                        c.globalAlpha = 0.95;
                        c.lineWidth = 1.5;
                        c.beginPath();
                        for (var j = 0; j < a.length; j++) {
                            var xx = x0 + j * step, yy = height - 1.5 - a[j] * (height - 3);
                            if (j === 0) c.moveTo(xx, yy); else c.lineTo(xx, yy);
                        }
                        c.stroke();
                    }
                }
            }
        }

        Rectangle {
            x: root.u * 1.4
            y: root.rowsLeft * root.lineH + root.u * 0.2
            width: root.u * 0.65; height: root.u * 1.3
            color: root.accent
            opacity: root.cursorOn ? 1 : 0
        }
    }

    Timer {
        interval: 500; repeat: true; running: true
        onTriggered: root.cursorOn = !root.cursorOn
    }
    Timer {
        interval: 1000; repeat: true; running: true
        onTriggered: root.hot = (root.hot + 1) % root.rows
    }
}
