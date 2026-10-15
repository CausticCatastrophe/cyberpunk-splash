import QtQuick
import ".."

// Animated version of the login/lock wallpaper: drifting grid, glitching
// title, and CRT effects. Settings come from the
// built-in defaults in SystemInfo.qml next to this file.
Item {
    id: root

    SystemInfo { id: sys }

    readonly property color accent: sys.accent
    readonly property color secondary: sys.secondary
    readonly property color fg: "#e8e6d9"
    readonly property real u: width / 100   // 1 unit = 1% of the width

    // bundled fonts (SIL OFL, see contents/fonts/); system fonts if they are missing
    FontLoader { id: fBold; source: Qt.resolvedUrl("../../fonts/Rajdhani-Bold.ttf") }
    FontLoader { id: fSemi; source: Qt.resolvedUrl("../../fonts/Rajdhani-SemiBold.ttf") }
    FontLoader { id: fMono; source: Qt.resolvedUrl("../../fonts/ShareTechMono-Regular.ttf") }
    readonly property string headName: fBold.status === FontLoader.Ready ? fBold.name : "Noto Sans"
    readonly property string subName: fSemi.status === FontLoader.Ready ? fSemi.name : "Noto Sans"
    readonly property string monoName: fMono.status === FontLoader.Ready ? fMono.name : "monospace"

    Item {
        id: scene
        anchors.fill: parent

        Rectangle { anchors.fill: parent; color: "#050506" }

        // grid that drifts down one cell, then repeats seamlessly
        Item {
            id: gridWrap
            width: parent.width
            height: parent.height + root.u * 4
            y: -root.u * 4
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var c = getContext("2d");
                    c.reset();
                    c.strokeStyle = root.accent;
                    c.globalAlpha = 0.11;
                    c.lineWidth = 1;
                    var s = root.u * 4;
                    for (var x = 0; x < width; x += s) { c.beginPath(); c.moveTo(x, 0); c.lineTo(x, height); c.stroke(); }
                    for (var y = 0; y < height; y += s) { c.beginPath(); c.moveTo(0, y); c.lineTo(width, y); c.stroke(); }
                }
            }
            NumberAnimation on y {
                from: -root.u * 4
                to: 0
                duration: 7000
                loops: Animation.Infinite
                running: true
            }
        }

        // glow rising from the bottom edge
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height * 0.45
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.24) }
            }
        }

        // title with a secondary-colored ghost and periodic colored glitch slices
        Item {
            id: titleBlock
            visible: sys.showTitle
            width: root.width
            height: root.u * 13
            y: root.height * sys.titleY

            component TitleText: Text {
                width: root.width
                horizontalAlignment: Text.AlignHCenter
                text: sys.title.toUpperCase()
                font.family: sys.titleFont !== "" && Qt.fontFamilies().indexOf(sys.titleFont) >= 0 ? sys.titleFont : root.headName
                font.weight: Font.Bold
                font.pixelSize: root.u * 11 * sys.titleScale
                font.letterSpacing: root.u * 0.7 * sys.titleScale
            }

            TitleText { x: -root.u * 0.3; color: root.secondary; opacity: 0.22 }
            TitleText { color: root.fg; opacity: 0.65 }

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
            GlitchBand { id: bandA; tint: root.secondary }
            GlitchBand { id: bandB; tint: root.accent }

            SequentialAnimation {
                running: sys.glitchTitle
                loops: Animation.Infinite
                PauseAnimation { duration: 2880 }
                ScriptAction { script: { bandA.topF = 0.20; bandA.botF = 0.55; bandA.dx = -root.u * 0.6 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandA.topF = 0.62; bandA.botF = 0.08; bandA.dx = root.u * 0.5 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandA.topF = 0.40; bandA.botF = 0.40; bandA.dx = -root.u * 0.3 } }
                PauseAnimation { duration: 128 }
                ScriptAction { script: { bandA.topF = 0.5; bandA.botF = 0.5; bandA.dx = 0 } }
            }
            SequentialAnimation {
                running: sys.glitchTitle
                loops: Animation.Infinite
                PauseAnimation { duration: 2912 }
                ScriptAction { script: { bandB.topF = 0.58; bandB.botF = 0.12; bandB.dx = root.u * 0.6 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandB.topF = 0.10; bandB.botF = 0.70; bandB.dx = -root.u * 0.5 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandB.topF = 0.35; bandB.botF = 0.45; bandB.dx = root.u * 0.3 } }
                PauseAnimation { duration: 96 }
                ScriptAction { script: { bandB.topF = 0.5; bandB.botF = 0.5; bandB.dx = 0 } }
            }

            Text {
                y: root.u * 11.6
                width: root.width
                horizontalAlignment: Text.AlignHCenter
                text: sys.tagline.toUpperCase()
                color: root.accent
                opacity: 0.75
                font.family: root.subName
                font.weight: Font.DemiBold
                font.pixelSize: root.u * 1.4
                font.letterSpacing: root.u * 0.84
            }
        }

        // rule and caption near the bottom
        Rectangle { x: root.u * 30; width: root.u * 40; y: root.height * 0.88; height: 1; color: root.accent; opacity: 0.35 }
        Text {
            y: root.height * 0.88 + root.u * 0.8
            width: root.width
            horizontalAlignment: Text.AlignHCenter
            text: "AUTHENTICATION REQUIRED"
            color: root.accent
            opacity: 0.55
            font.family: root.monoName
            font.pixelSize: root.u * 1.0
            font.letterSpacing: root.u * 0.4
        }

        // corner brackets
        component Bracket: Item {
            property bool atTop: true
            property bool atLeft: true
            width: root.u * 3
            height: width
            opacity: 0.9
            Rectangle { width: parent.width; height: 2; color: root.accent; y: parent.atTop ? 0 : parent.height - 2 }
            Rectangle { width: 2; height: parent.height; color: root.accent; x: parent.atLeft ? 0 : parent.width - 2 }
        }
        Bracket { atTop: true;  atLeft: true;  x: root.u * 1.4; y: root.u * 1.4 }
        Bracket { atTop: true;  atLeft: false; x: root.width - width - root.u * 1.4; y: root.u * 1.4 }
        Bracket { atTop: false; atLeft: true;  x: root.u * 1.4; y: root.height - height - root.u * 1.4 }
        Bracket { atTop: false; atLeft: false; x: root.width - width - root.u * 1.4; y: root.height - height - root.u * 1.4 }

        // vignette
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.35) }
                GradientStop { position: 0.25; color: "transparent" }
                GradientStop { position: 0.75; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.35) }
            }
        }
    }

    // CRT tear: a strip of the picture is redrawn shifted sideways
    Rectangle {
        id: tear
        property real dx: 0
        property real sliceY: 0
        property real sliceH: 0
        y: sliceY
        width: root.width
        height: sliceH
        color: "#050506"
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
        ScriptAction { script: { tear.sliceY = root.height * 0.62; tear.sliceH = root.height * 0.05; tear.dx = root.u * 1.2; scene.x = root.u * 0.3 } }
        PauseAnimation { duration: 70 }
        ScriptAction { script: { tear.sliceY = root.height * 0.20; tear.sliceH = root.height * 0.03; tear.dx = -root.u * 1.8; scene.x = -root.u * 0.2 } }
        PauseAnimation { duration: 60 }
        ScriptAction { script: { tear.sliceY = root.height * 0.80; tear.sliceH = root.height * 0.02; tear.dx = root.u * 0.9; scene.x = 0 } }
        PauseAnimation { duration: 70 }
        ScriptAction { script: { tear.sliceH = 0; tear.dx = 0; scene.x = 0 } }
        PauseAnimation { duration: 2500 }
    }

    // slow refresh bar
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

    // brightness flicker
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

    // scanlines
    Canvas {
        anchors.fill: parent
        visible: sys.scanlines
        onPaint: {
            var c = getContext("2d");
            c.reset();
            c.fillStyle = "rgba(0,0,0,0.18)";
            for (var y = 0; y < height; y += 3) c.fillRect(0, y, width, 1);
        }
    }
}
