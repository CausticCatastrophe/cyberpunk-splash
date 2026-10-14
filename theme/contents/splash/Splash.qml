import QtQuick

// Stage-driven splash. Plasma sets `stage` (0..6) as the session starts;
// everything below is a function of that one number plus SystemInfo.
Rectangle {
    id: root
    color: "#050506"

    property int stage: 0

    readonly property color accent: sys.accent
    readonly property color secondary: sys.secondary
    readonly property color fg: "#e8e6d9"
    readonly property color dim: "#b9b7a3"
    readonly property real u: width / 100   // 1 unit = 1% of screen width
    // bundled fonts (SIL OFL, see fonts/); system fonts only if loading fails
    FontLoader { id: rajdhaniBold; source: "fonts/Rajdhani-Bold.ttf" }
    FontLoader { id: rajdhaniSemi; source: "fonts/Rajdhani-SemiBold.ttf" }
    FontLoader { id: shareTechMono; source: "fonts/ShareTechMono-Regular.ttf" }
    readonly property string headName: rajdhaniBold.status === FontLoader.Ready ? rajdhaniBold.name : "Noto Sans"
    readonly property string subName: rajdhaniSemi.status === FontLoader.Ready ? rajdhaniSemi.name : "Noto Sans"
    readonly property string monoName: shareTechMono.status === FontLoader.Ready ? shareTechMono.name : "monospace"
    readonly property int maxStage: 6
    // read live from Qt, so it reflects the session the splash is running in
    readonly property string session: {
        var p = Qt.platform.pluginName;
        if (p.indexOf("wayland") === 0) return "wayland";
        if (p === "xcb") return "x11";
        return p;
    }

    readonly property var steps: [
        "initializing session", "session manager", "compositor",
        "desktop shell", "panels and widgets", "restoring apps", "welcome back"
    ]
    readonly property var logLines: [
        ["a", "session ........... started"],
        ["a", "kwin_wayland ....... online"],
        ["s", "plasmashell ....... loading"],
        ["s", "panels ............ drawing"],
        ["a", "apps .............. restored"],
        ["a", "desktop ............ ready"]
    ]

    SystemInfo { id: sys }
    component HudText: Text {
        color: root.accent
        opacity: 0.8
        font.family: root.monoName
        font.pixelSize: root.u * 1.0
        font.letterSpacing: root.u * 0.16
    }

    component Bracket: Item {
        property bool atTop: true
        property bool atLeft: true
        width: root.u * 3
        height: width
        Rectangle { width: parent.width; height: 2; color: root.accent; y: parent.atTop ? 0 : parent.height - 2 }
        Rectangle { width: 2; height: parent.height; color: root.accent; x: parent.atLeft ? 0 : parent.width - 2 }
    }

    // everything visible lives in `scene` so the CRT tear can sample it
    Item {
        id: scene
        anchors.fill: parent

        // faint grid
        Canvas {
            anchors.fill: parent
            onPaint: {
                var c = getContext("2d");
                c.reset();
                c.strokeStyle = root.accent; c.globalAlpha = 0.06;
                c.lineWidth = 1;
                var s = root.u * 4;
                for (var x = 0; x < width; x += s) { c.beginPath(); c.moveTo(x, 0); c.lineTo(x, height); c.stroke(); }
                for (var y = 0; y < height; y += s) { c.beginPath(); c.moveTo(0, y); c.lineTo(width, y); c.stroke(); }
            }
        }

        // frame
        Bracket { atTop: true;  atLeft: true;  x: root.u * 1.4; y: root.u * 1.4 }
        Bracket { atTop: true;  atLeft: false; x: root.width - width - root.u * 1.4; y: root.u * 1.4 }
        Bracket { atTop: false; atLeft: true;  x: root.u * 1.4; y: root.height - height - root.u * 1.4 }
        Bracket { atTop: false; atLeft: false; x: root.width - width - root.u * 1.4; y: root.height - height - root.u * 1.4 }

        HudText { x: root.u * 2.4; y: root.u * 2.2; text: [sys.osName, sys.hostname].filter(function (s) { return s !== "" }).join(" // ").toUpperCase() }
        HudText { x: root.width - width - root.u * 2.4; y: root.u * 2.2; text: sys.kernel !== "" ? ("KERNEL " + sys.kernel).toUpperCase() : "" }
        HudText { x: root.u * 2.4; y: root.height - height - root.u * 2.2; text: sys.plasma !== "" ? ("PLASMA " + sys.plasma).toUpperCase() : "" }
        HudText { x: root.width - width - root.u * 2.4; y: root.height - height - root.u * 2.2; text: [sys.qt !== "" ? "QT " + sys.qt : "", root.session].filter(function (s) { return s !== "" }).join(" // ").toUpperCase() }

        // title with a periodic RGB-split glitch
        Item {
            id: titleBlock
            width: root.width
            height: root.u * 11
            y: root.height * 0.24 - height / 2

            component TitleText: Text {
                width: root.width
                horizontalAlignment: Text.AlignHCenter
                text: sys.title.toUpperCase()
                font.family: root.headName
                font.weight: Font.Bold
                font.pixelSize: root.u * 8.5
                font.letterSpacing: root.u * 0.51
            }

            TitleText { color: root.fg }

            // A glitch band shows only a horizontal slice of the title, shifted
            // sideways. topF/botF are the fractions hidden above and below.
            component GlitchBand: Item {
                property color tint
                property real topF: 0.5
                property real botF: 0.5
                property real dx: 0
                clip: true
                width: root.width
                y: titleBlock.height * topF
                height: titleBlock.height * Math.max(0, 1 - topF - botF)
                TitleText {
                    color: parent.tint
                    y: -parent.y
                    x: parent.dx
                }
            }

            GlitchBand { id: bandCyan; tint: root.secondary }
            GlitchBand { id: bandAccent; tint: root.accent }

            // timings follow a 3.2 s cycle: cyan fires at 90/93/96 %, accent at 91/94/97 %
            SequentialAnimation {
                running: sys.glitchTitle
                loops: Animation.Infinite
                PauseAnimation { duration: 2880 }
                ScriptAction { script: { bandCyan.topF = 0.20; bandCyan.botF = 0.55; bandCyan.dx = -root.u * 0.6 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandCyan.topF = 0.62; bandCyan.botF = 0.08; bandCyan.dx = root.u * 0.5 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandCyan.topF = 0.40; bandCyan.botF = 0.40; bandCyan.dx = -root.u * 0.3 } }
                PauseAnimation { duration: 128 }
                ScriptAction { script: { bandCyan.topF = 0.5; bandCyan.botF = 0.5; bandCyan.dx = 0 } }
            }
            SequentialAnimation {
                running: sys.glitchTitle
                loops: Animation.Infinite
                PauseAnimation { duration: 2912 }
                ScriptAction { script: { bandAccent.topF = 0.58; bandAccent.botF = 0.12; bandAccent.dx = root.u * 0.6 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandAccent.topF = 0.10; bandAccent.botF = 0.70; bandAccent.dx = -root.u * 0.5 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandAccent.topF = 0.35; bandAccent.botF = 0.45; bandAccent.dx = root.u * 0.3 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandAccent.topF = 0.5; bandAccent.botF = 0.5; bandAccent.dx = 0 } }
            }
        }

        Text {
            y: root.height * 0.24 + root.u * 5.2
            width: root.width
            horizontalAlignment: Text.AlignHCenter
            text: sys.tagline.toUpperCase()
            color: root.fg
            font.family: root.subName
            font.weight: Font.DemiBold
            font.pixelSize: root.u * 1.4
            font.letterSpacing: root.u * 0.84
        }

        // boot log: one line per stage, cursor on the next free row
        Item {
            id: log
            readonly property real lineH: root.u * 1.25 * 1.75
            x: root.width / 2 - root.u * 23
            y: root.height * 0.5
            width: root.u * 46
            height: lineH * 7

            Rectangle { x: 0; y: 0; width: 2; height: parent.height; color: root.accent }

            Repeater {
                model: root.logLines
                Text {
                    required property int index
                    required property var modelData
                    x: root.u * 1.6
                    y: index * log.lineH
                    height: log.lineH
                    verticalAlignment: Text.AlignVCenter
                    textFormat: Text.StyledText
                    color: root.dim
                    font.family: root.monoName
                    font.pixelSize: root.u * 1.25
                    text: "<font color='" + (modelData[0] === "a" ? root.accent : root.secondary) + "'>&gt;</font> " + modelData[1]
                    opacity: index < root.stage ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }

            Rectangle {
                x: root.u * 1.6
                y: root.stage * log.lineH + (log.lineH - height) / 2
                width: root.u * 0.7
                height: root.u * 1.3
                color: root.accent
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0; duration: 1; }
                    PauseAnimation { duration: 500 }
                    NumberAnimation { to: 1; duration: 1 }
                    PauseAnimation { duration: 500 }
                }
            }
        }

        // progress
        Item {
            id: loader
            width: root.u * 46
            height: root.u * 3.2
            x: root.width / 2 - width / 2
            y: root.height - root.u * 6.5 - height

            Text {
                anchors.left: parent.left
                text: (root.stage >= root.maxStage && sys.userName !== ""
                       ? "welcome back, " + sys.userName
                       : root.steps[Math.min(root.stage, root.maxStage)]).toUpperCase()
                color: root.accent
                font.family: root.monoName
                font.pixelSize: root.u * 1.1
                font.letterSpacing: root.u * 0.176
            }
            Text {
                anchors.right: parent.right
                text: "STAGE " + Math.min(root.stage, root.maxStage) + "/" + root.maxStage
                color: root.fg
                font.family: root.monoName
                font.pixelSize: root.u * 1.1
                font.letterSpacing: root.u * 0.176
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: root.u * 1.1
                color: "transparent"
                border.color: root.accent
                border.width: 1

                Row {
                    x: 3
                    y: 3
                    spacing: 2
                    Repeater {
                        model: 48
                        Rectangle {
                            required property int index
                            readonly property real segW: (loader.width - 6 - 47 * 2) / 48
                            width: segW
                            height: root.u * 1.1 - 6
                            color: root.accent
                            opacity: index < (Math.min(root.stage, root.maxStage) / root.maxStage) * 48 ? 1 : 0.1
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }

    }

    // CRT tear: a strip of the picture is re-drawn shifted sideways while the
    // whole frame jitters, like a loose horizontal-hold signal
    Rectangle {
        id: tear
        property real dx: 0
        property real sliceY: 0
        property real sliceH: 0
        y: sliceY
        width: root.width
        height: sliceH
        color: root.color
        visible: sliceH > 0
        clip: true
        ShaderEffectSource {
            sourceItem: scene
            sourceRect: Qt.rect(0, tear.sliceY, root.width, tear.sliceH)
            x: tear.dx
            width: root.width
            height: tear.sliceH
            live: true
        }
    }

    SequentialAnimation {
        running: sys.crtTear
        loops: Animation.Infinite
        PauseAnimation { duration: 4300 }
        ScriptAction { script: {
            tear.sliceY = root.height * 0.62; tear.sliceH = root.height * 0.05
            tear.dx = root.u * 1.2; scene.x = root.u * 0.3 } }
        PauseAnimation { duration: 70 }
        ScriptAction { script: {
            tear.sliceY = root.height * 0.20; tear.sliceH = root.height * 0.03
            tear.dx = -root.u * 1.8; scene.x = -root.u * 0.2 } }
        PauseAnimation { duration: 60 }
        ScriptAction { script: {
            tear.sliceY = root.height * 0.80; tear.sliceH = root.height * 0.02
            tear.dx = root.u * 0.9; scene.x = 0 } }
        PauseAnimation { duration: 70 }
        ScriptAction { script: { tear.sliceH = 0; tear.dx = 0; scene.x = 0 } }
        PauseAnimation { duration: 2500 }
    }

    // slow refresh bar rolling down the screen
    Rectangle {
        id: rollBar
        visible: sys.crtRoll
        width: root.width
        height: root.height * 0.14
        y: -height
        opacity: 0.07
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: "white" }
            GradientStop { position: 1.0; color: "transparent" }
        }
        SequentialAnimation on y {
            running: sys.crtRoll
            loops: Animation.Infinite
            PauseAnimation { duration: 2500 }
            NumberAnimation { from: -rollBar.height; to: root.height; duration: 5500 }
        }
    }

    // brief brightness flicker
    Rectangle {
        id: flicker
        visible: sys.crtFlicker
        anchors.fill: parent
        color: "black"
        opacity: 0
        SequentialAnimation on opacity {
            running: sys.crtFlicker
            loops: Animation.Infinite
            PauseAnimation { duration: 1700 }
            NumberAnimation { to: 0.08; duration: 30 }
            NumberAnimation { to: 0; duration: 30 }
            PauseAnimation { duration: 900 }
            NumberAnimation { to: 0.05; duration: 30 }
            NumberAnimation { to: 0; duration: 30 }
            PauseAnimation { duration: 3100 }
        }
    }

    // scanlines on top
    Canvas {
        anchors.fill: parent
        visible: sys.scanlines
        z: 10
        onPaint: {
            var c = getContext("2d");
            c.reset();
            c.fillStyle = "rgba(0,0,0,0.28)";
            for (var y = 0; y < height; y += 3) c.fillRect(0, y, width, 1);
        }
    }
}
