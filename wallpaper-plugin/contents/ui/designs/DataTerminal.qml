import QtQuick
import ".."

// The screen is split into three vertical segments, all on the background grid:
//   left gutter   identity block, then live CPU and GPU panels
//   centre        the clock, title and tagline, kept clear of everything else
//   right gutter  one terminal: CPU readings, the CPU core map, GPU readings
// The gutters are four grid cells wide, one cell in from each side. The terminal is a
// dense, left-justified list: short labels, compact values and a small graph of each
// reading's recent history. CPU lines use the accent color, GPU lines the secondary
// color. It shows real readings when the wallpaper runs on a screen, and static facts
// in a still image. Nothing identifying is shown: no user names, addresses, processes
// or files.
// Motion budget (about 1 frame a second, close to free): readings, graphs and core tiles
// update every few seconds, and the clock redraws once a minute.
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
    property string sparkScale: sys.sparkScale     // "auto" fits the range to the data, "fixed" uses the full range
    property bool sparkSmooth: sys.sparkSmooth     // curved line, like the System Monitor widgets
    property bool showGpuPanel: sys.gpuPanel
    property bool showCoreMap: sys.coreMap
    // sensor ids to use instead of the built-in ones (see LiveStats); the wallpaper
    // plugin sets this per screen
    property var sensorIds: ({ cpu: sys.sensorCpu, cputemp: sys.sensorCpuTemp, memused: sys.sensorMemUsed,
                               memtotal: sys.sensorMemTotal, gpu: sys.sensorGpu, gputemp: sys.sensorGpuTemp,
                               vramused: sys.sensorVramUsed, vramtotal: sys.sensorVramTotal,
                               uptime: sys.sensorUptime, case: sys.caseSensor,
                               gpuname: sys.sensorGpuName, gpuclock: sys.sensorGpuClock,
                               gpupower: sys.sensorGpuPower, gpufan: sys.sensorGpuFan,
                               gpujunction: sys.sensorGpuJunction, corecount: sys.sensorCoreCount })

    // sparkline history, as fractions 0..1 per reading
    readonly property int histLen: sparkPoints
    property var hist: ({})
    property int histTick: 0

    Loader {
        id: live
        active: root.liveStats
        source: "LiveStats.qml"
    }
    Binding { target: live.item; property: "ids"; value: root.sensorIds; when: live.status === Loader.Ready }
    Binding { target: live.item; property: "interval"; value: root.logRefresh * 1000; when: live.status === Loader.Ready }

    // ---- the grid and the segments ----
    // The background grid has square cells 4% of the screen width wide.
    readonly property real cell: u * 4
    readonly property real marginX: cell
    readonly property real gutterW: cell * 4                 // each side gutter is four cells wide
    readonly property real rightX: width - marginX - gutterW // left edge of the right gutter
    // The lower blocks end on the last grid line above the bottom margin. When a bottom
    // margin is set (a taskbar), that panel already gives the breathing room, so only a
    // little extra is kept; otherwise 3.5 units.
    readonly property real bottomLine: Math.floor((height - insetPx - (insetPx > 0 ? u * 0.8 : u * 3.5)) / cell) * cell
    readonly property real rowH: cell / 2                    // two terminal rows to a grid cell

    // ---- formatting helpers ----
    function gib(bytes) { return (bytes / 1073741824).toFixed(1); }
    function pct(v) { return Math.round(v) + "%"; }
    function deg(v) { return Math.round(v) + "C"; }
    function clamp(f) { return Math.max(0, Math.min(1, f)); }
    function uptimeText(s) {
        var d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60);
        return d > 0 ? d + "d " + h + "h" : (h > 0 ? h + "h " + m + "m" : m + "m");
    }
    // compact "used/total" with one unit: 5.9/46.9G
    function pair(used, total) { return gib(used) + "/" + gib(total) + "G"; }
    function mhz(v) { return v >= 1000 ? (v / 1000).toFixed(2) + " GHz" : Math.round(v) + " MHz"; }
    // "Navi 31 [...] (Radeon RX 7900 XTX)" -> "Radeon RX 7900 XTX"
    function gpuModel(name) {
        var a = name.lastIndexOf("("), b = name.lastIndexOf(")");
        return a >= 0 && b > a ? name.substring(a + 1, b) : name;
    }

    // One terminal line. c is the color group ("a" accent, "s" secondary); key and f feed
    // the graph (key is empty for lines without one). span is the smallest part of the
    // 0..1 range that auto-range will zoom in to.
    function line(label, value, c, key, f, span) {
        return { label: label, value: value, c: c, key: key, f: f, span: span };
    }

    // The line for an item name, or null when it has no value to show.
    function entry(name) {
        var L = live.item;
        switch (name) {
        case "cpu":
            return L && isFinite(L.cpu) ? line("usage", pct(L.cpu), "a", "cpu", clamp(L.cpu / 100), 0.10) : null;
        case "cputemp":
            return L && isFinite(L.temp) && L.temp > 0 ? line("temp", deg(L.temp), "a", "cputemp", clamp((L.temp - 25) / 70), 0.06) : null;
        case "mem":
            return L && L.memTotal > 0 ? line("ram", pair(L.memUsed, L.memTotal), "a", "mem", clamp(L.memUsed / L.memTotal), 0.02) : null;
        case "gpu":
            return L && isFinite(L.gpu) ? line("usage", pct(L.gpu), "s", "gpu", clamp(L.gpu / 100), 0.10) : null;
        case "gputemp":
            return L && isFinite(L.gpuTemp) && L.gpuTemp > 0 ? line("temp", deg(L.gpuTemp), "s", "gputemp", clamp((L.gpuTemp - 25) / 70), 0.06) : null;
        case "vram":
            return L && L.vramTotal > 0 ? line("vram", pair(L.vramUsed, L.vramTotal), "s", "vram", clamp(L.vramUsed / L.vramTotal), 0.02) : null;
        case "case":
            return L && isFinite(L.caseTemp) && L.caseTemp > 0 ? line("case", deg(L.caseTemp), "a", "casetemp", clamp((L.caseTemp - 15) / 50), 0.06) : null;
        case "uptime":  return L && L.uptime > 0 ? line("uptime", uptimeText(L.uptime), "a", "", 0, 0) : null;
        case "os":      return sys.osName !== "" ? line("os", sys.osName, "a", "", 0, 0) : null;
        case "kernel":  return sys.kernel !== "" ? line("kernel", sys.kernel, "a", "", 0, 0) : null;
        case "plasma":  return sys.plasma !== "" ? line("plasma", sys.plasma, "a", "", 0, 0) : null;
        case "qt":      return sys.qt !== "" ? line("qt", sys.qt, "a", "", 0, 0) : null;
        case "host":    return sys.hostname !== "" ? line("host", sys.hostname, "a", "", 0, 0) : null;
        }
        return null;
    }

    // The entries in list order.
    readonly property var entries: {
        var out = [], names = root.logItems.split(",");
        for (var i = 0; i < names.length && out.length < 14; i++) {
            var t = entry(names[i].trim());
            if (t !== null) out.push(t);
        }
        if (out.length === 0) {     // a still image with only live items listed
            var fb = [entry("plasma"), entry("qt")];
            for (var j = 0; j < fb.length; j++) if (fb[j] !== null) out.push(fb[j]);
        }
        return out;
    }

    // The terminal, top to bottom: a CPU group (header and lines), the core map, then a
    // GPU group. Rows are half a grid cell tall and the block ends on the bottom grid line.
    // The map's tiles are whole grid cells; a blank row goes before the GPU group when
    // needed so they land exactly on grid lines. at is a row offset from the block's top.
    readonly property int coreRows: showCoreMap && coreMap.item && coreMap.item.count > 0 ? coreMap.item.rowCount : 0
    readonly property var layout: {
        var rows = [], at = 0, coresAt = -1, cpuTop = -1, cpuEnd = 0, gpuTop = -1, gpuEnd = 0;
        var A = entries.filter(function (t) { return t.c !== "s"; });
        var S = entries.filter(function (t) { return t.c === "s"; });
        if (A.length > 0 || coreRows > 0) {
            cpuTop = at;
            rows.push({ kind: "head", text: "CPU", c: "a", at: at++ });
            for (var i = 0; i < A.length; i++)
                rows.push({ kind: "line", c: "a", label: A[i].label, value: A[i].value, key: A[i].key, f: A[i].f, span: A[i].span, at: at++ });
            if (coreRows > 0) { coresAt = at; at += 1 + coreRows * 2; }    // caption row + two rows per tile row
            cpuEnd = at;
        }
        if (S.length > 0) {
            if (coreRows > 0 && (1 + S.length) % 2 === 1) at++;            // keep the tiles on grid lines
            gpuTop = at;
            rows.push({ kind: "head", text: "GPU", c: "s", at: at++ });
            for (var j = 0; j < S.length; j++)
                rows.push({ kind: "line", c: "s", label: S[j].label, value: S[j].value, key: S[j].key, f: S[j].f, span: S[j].span, at: at++ });
            gpuEnd = at;
        }
        return { rows: rows, total: at, coresAt: coresAt, cpu: [cpuTop, cpuEnd], gpu: [gpuTop, gpuEnd] };
    }
    readonly property real termTop: bottomLine - layout.total * rowH

    // record one point per graph every sparkStep seconds
    function sample() {
        var h = hist, L = entries;
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

    // uptime for the identity block; hidden when the terminal already has its own line
    readonly property string identityUptime:
        live.item && live.item.uptime > 0 && root.logItems.split(",").indexOf("uptime") < 0
            ? uptimeText(live.item.uptime) : ""

    // session type, read from Qt; hidden when it is not a real display platform
    readonly property string session: {
        var p = Qt.platform.pluginName;
        if (p.indexOf("wayland") === 0) return "WAYLAND";
        if (p === "xcb") return "X11";
        return "";
    }

    // rows for the CPU panel; empty (so the panel is hidden) without live readings
    readonly property var cpuRows: {
        var L = live.item, out = [];
        if (!L || !showGpuPanel) return out;
        if (sys.cpuModel !== "") out.push(["CPU", sys.cpuModel]);
        if (isFinite(L.cpuClock)) out.push(["CLOCK", mhz(L.cpuClock)]);
        if (isFinite(L.cpuHot) && L.cpuHot > 0) out.push(["HOTTEST", Math.round(L.cpuHot) + " C"]);
        return out;
    }

    // rows for the GPU panel; empty (so the panel is hidden) without live readings
    readonly property var gpuRows: {
        var L = live.item, out = [];
        if (!L || !showGpuPanel) return out;
        if (L.gpuNameText !== "") out.push(["GPU", gpuModel(L.gpuNameText)]);
        if (isFinite(L.gpuClock)) out.push(["CLOCK", mhz(L.gpuClock)]);
        if (isFinite(L.gpuPower)) out.push(["POWER", Math.round(L.gpuPower) + " W"]);
        if (isFinite(L.gpuFan)) out.push(["FAN", Math.round(L.gpuFan) + " RPM"]);
        if (isFinite(L.gpuJunction) && L.gpuJunction > 0) out.push(["JUNCTION", Math.round(L.gpuJunction) + " C"]);
        return out;
    }

    // a label/value row for the identity block and the GPU panel; the value shrinks to fit
    component InfoRow: Item {
        id: info
        property string label: ""
        property string value: ""
        property color tint: root.accent
        width: root.gutterW
        height: valueText.implicitHeight
        visible: value !== ""
        Text {
            id: labelText
            width: root.u * 5.6
            text: info.label
            color: info.tint; opacity: 0.6
            font.family: root.monoFont
            font.pixelSize: root.u * 0.95
            font.letterSpacing: root.u * 0.12
        }
        Text {
            id: valueText
            x: root.u * 5.6
            width: info.width - root.u * 5.6
            text: info.value.toUpperCase()
            color: "#e8e6d9"; opacity: 0.8
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 7
            font.family: root.monoFont
            font.pixelSize: root.u * 0.95
            font.letterSpacing: root.u * 0.12
        }
    }

    // ---- left gutter, top: identity block ----
    Column {
        id: idCol
        x: root.marginX
        y: root.cell * 2
        spacing: root.u * 0.5
        Repeater {
            model: [["HOST", sys.hostname], ["OS", sys.osName], ["KERNEL", sys.kernel], ["SESSION", root.session], ["UPTIME", root.identityUptime]]
            InfoRow { required property var modelData; label: modelData[0]; value: modelData[1] }
        }
    }

    // ---- left gutter, under the identity block: CPU panel (accent), then GPU panel (secondary) ----
    // Each starts on a grid line below the block above it.
    Column {
        id: cpuCol
        x: root.marginX
        y: Math.ceil((idCol.y + idCol.height + root.u) / root.cell) * root.cell
        spacing: root.u * 0.5
        Repeater {
            model: root.cpuRows
            InfoRow { required property var modelData; label: modelData[0]; value: modelData[1] }
        }
    }
    Column {
        x: root.marginX
        y: Math.ceil((cpuCol.y + cpuCol.height + root.u) / root.cell) * root.cell
        spacing: root.u * 0.5
        Repeater {
            model: root.gpuRows
            InfoRow { required property var modelData; label: modelData[0]; value: modelData[1]; tint: root.secondary }
        }
    }

    Binding { target: coreMap.item; property: "accent"; value: root.accent; when: coreMap.status === Loader.Ready }
    Binding { target: coreMap.item; property: "monoFont"; value: root.monoFont; when: coreMap.status === Loader.Ready }
    Binding { target: coreMap.item; property: "u"; value: root.u; when: coreMap.status === Loader.Ready }
    Binding { target: coreMap.item; property: "cell"; value: root.cell; when: coreMap.status === Loader.Ready }
    Binding { target: coreMap.item; property: "columns"; value: 4; when: coreMap.status === Loader.Ready }
    // the same text column as the headers and readings: one inset from the bar, out to the graphs' right edge
    Binding { target: coreMap.item; property: "contentX"; value: root.u * 1.2; when: coreMap.status === Loader.Ready }
    Binding { target: coreMap.item; property: "contentW"; value: root.gutterW - root.u * 1.2; when: coreMap.status === Loader.Ready }
    Binding { target: coreMap.item; property: "interval"; value: root.logRefresh * 1000; when: coreMap.status === Loader.Ready }
    Binding {
        target: coreMap.item; property: "countSensor"
        value: root.sensorIds.corecount !== undefined && root.sensorIds.corecount !== "" ? root.sensorIds.corecount : "cpu/all/coreCount"
        when: coreMap.status === Loader.Ready
    }

    // ---- right gutter, bottom: the terminal ----
    Item {
        id: terminal
        x: root.rightX
        y: root.termTop
        width: root.gutterW
        height: root.layout.total * root.rowH

        // the CPU group's side bar runs from its header through the core map; the GPU group has its own
        Rectangle {
            visible: root.layout.cpu[1] > root.layout.cpu[0]
            y: root.layout.cpu[0] * root.rowH
            width: 2; height: (root.layout.cpu[1] - root.layout.cpu[0]) * root.rowH
            color: root.accent; opacity: 0.8
        }
        Rectangle {
            visible: root.layout.gpu[1] > root.layout.gpu[0]
            y: root.layout.gpu[0] * root.rowH
            width: 2; height: (root.layout.gpu[1] - root.layout.gpu[0]) * root.rowH
            color: root.secondary; opacity: 0.8
        }

        // CPU core map, between the CPU and GPU groups
        Loader {
            id: coreMap
            active: root.liveStats && root.showCoreMap
            source: "CoreMap.qml"
            x: 0
            y: root.layout.coresAt * root.rowH
        }

        Repeater {
            model: root.layout.rows
            Item {
                id: row
                required property var modelData
                readonly property color tint: modelData.c === "s" ? root.secondary : root.accent
                x: root.u * 1.2
                y: modelData.at * root.rowH
                width: root.gutterW - root.u * 1.2
                height: root.rowH

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: row.tint
                    opacity: row.modelData.kind === "head" ? 0.6 : 0.92
                    font.family: root.monoFont
                    font.pixelSize: root.u * (row.modelData.kind === "head" ? 0.95 : 1.0)
                    font.letterSpacing: row.modelData.kind === "head" ? root.u * 0.2 : 0
                    text: row.modelData.kind === "head"
                          ? row.modelData.text
                          : (row.modelData.label + "       ").substring(0, Math.max(7, row.modelData.label.length + 1)) + row.modelData.value
                }

                // history of this reading, newest on the right
                Canvas {
                    id: spark
                    visible: row.modelData.kind === "line" && row.modelData.key !== ""
                    x: root.u * 9.2
                    y: (row.height - height) / 2
                    width: root.u * 5.6
                    height: root.u * 1.2
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

                        // vertical range: the whole 0..1 span, or zoomed to the data (never
                        // tighter than the line's minimum span, so noise is not blown up)
                        var lo = 0, hi = 1;
                        if (root.sparkScale === "auto") {
                            lo = Math.min.apply(null, a);
                            hi = Math.max.apply(null, a);
                            var span = row.modelData.span > 0 ? row.modelData.span : 0.05;
                            if (hi - lo < span) { var mid = (hi + lo) / 2; lo = mid - span / 2; hi = mid + span / 2; }
                            if (lo < 0) { hi -= lo; lo = 0; }
                            if (hi > 1) { lo = Math.max(0, lo - (hi - 1)); hi = 1; }
                        }
                        var rng = Math.max(hi - lo, 0.0001);
                        var step = width / (root.histLen - 1), x0 = width - (a.length - 1) * step;
                        function yOf(v) { return height - 1.5 - ((v - lo) / rng) * (height - 3); }

                        // the line, straight or smoothed through the midpoints
                        function trace() {
                            c.beginPath();
                            var px = x0, py = yOf(a[0]);
                            c.moveTo(px, py);
                            for (var i = 1; i < a.length; i++) {
                                var x = x0 + i * step, y = yOf(a[i]);
                                if (root.sparkSmooth) c.quadraticCurveTo(px, py, (px + x) / 2, (py + y) / 2);
                                else c.lineTo(x, y);
                                px = x; py = y;
                            }
                            c.lineTo(px, py);
                        }
                        trace();
                        c.lineTo(width, height - 0.5);
                        c.lineTo(x0, height - 0.5);
                        c.closePath();
                        c.globalAlpha = 0.10;      // the same light fill as the System Monitor charts
                        c.fill();
                        trace();
                        c.globalAlpha = 0.95;
                        c.lineWidth = 1.5;
                        c.stroke();
                    }
                }
            }
        }
    }
}
