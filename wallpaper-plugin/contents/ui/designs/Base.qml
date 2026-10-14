import QtQuick

// Shared frame for the wallpaper concepts: grid, title, brackets, vignette and
// scanlines. A design puts its own layer inside this item; that layer sits
// above the grid and below the title.
Rectangle {
    id: root
    color: "#050506"

    property color accent: "#fcee09"
    property color secondary: "#02d7f2"
    property string title: "CYBERPUNK"
    property string tagline: "OS // neural desktop"
    property real titleY: 0.40
    property bool showTitle: true
    property string titleFont: ""      // an installed font for the title; empty uses headFont
    property real titleScale: 1.0      // size multiplier, for fonts that run wide or narrow
    property string taglineFont: ""    // the tagline's own font; empty uses headFont
    // Raises everything anchored to the bottom edge, as a fraction of the height, so
    // a panel along the bottom does not cover it. Set per screen in the settings.
    property real bottomInset: 0
    readonly property real insetPx: height * bottomInset
    readonly property real usableH: height - insetPx
    // the title font if Qt can find it, otherwise the regular head font
    readonly property string titleFamily:
        titleFont !== "" && Qt.fontFamilies().indexOf(titleFont) >= 0 ? titleFont : headFont
    readonly property string taglineFamily:
        taglineFont !== "" && Qt.fontFamilies().indexOf(taglineFont) >= 0 ? taglineFont : headFont
    property string headFont: "Rajdhani"
    property string monoFont: "Share Tech Mono"

    readonly property real u: width / 100   // 1 unit = 1% of the width

    default property alias content: slot.data

    Canvas {
        anchors.fill: parent
        onPaint: {
            var c = getContext("2d");
            c.reset();
            c.strokeStyle = root.accent;
            c.globalAlpha = 0.07;
            c.lineWidth = 1;
            var s = root.u * 4;
            for (var x = 0; x < width; x += s) { c.beginPath(); c.moveTo(x, 0); c.lineTo(x, height); c.stroke(); }
            for (var y = 0; y < height; y += s) { c.beginPath(); c.moveTo(0, y); c.lineTo(width, y); c.stroke(); }
        }
    }

    Item { id: slot; anchors.fill: parent }

    // title: a secondary-colored ghost behind a light copy, then the tagline
    Item {
        visible: root.showTitle
        width: root.width
        height: root.u * 13
        y: root.height * root.titleY
        component TitleText: Text {
            x: root.u * 20
            width: root.u * 60                  // the title may use the middle 60% of the width
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.HorizontalFit    // a wide font shrinks to fit, never overlaps the side columns
            minimumPixelSize: 8
            // how much it had to shrink (1 = not at all); the tagline follows it up
            readonly property real fit: fontInfo.pixelSize > 0
                ? Math.min(1, fontInfo.pixelSize / (root.u * 11 * root.titleScale)) : 1
            text: root.title
            font.family: root.titleFamily
            font.weight: Font.Bold
            font.pixelSize: root.u * 11 * root.titleScale
            font.letterSpacing: root.u * 0.7 * root.titleScale
        }
        TitleText { x: root.u * 19.7; color: root.secondary; opacity: 0.22 }
        TitleText { id: mainTitle; color: "#e8e6d9"; opacity: 0.65 }
        Text {
            y: root.u * 11.6 * root.titleScale * mainTitle.fit
            width: root.width
            horizontalAlignment: Text.AlignHCenter
            text: root.tagline.toUpperCase()
            color: root.accent
            opacity: 0.75
            font.family: root.taglineFamily
            font.weight: Font.DemiBold
            font.pixelSize: root.u * 1.4
            font.letterSpacing: root.u * 0.84
        }
    }

    // clock: redraws once a minute, aligned to the minute, so it costs almost nothing
    property bool showClock: true
    property bool clock24h: false
    property real clockY: 0.14
    property date now: new Date()

    Item {
        visible: root.showClock
        width: root.width
        y: root.height * root.clockY
        Text {
            id: timeText
            width: root.width
            horizontalAlignment: Text.AlignHCenter
            // "hh" only means 12-hour when the format also has AP, so format with it and strip it
            text: Qt.formatTime(root.now, root.clock24h ? "HH:mm" : "hh:mm AP").replace(/\s*[^\d:]+$/, "")
            color: root.accent
            opacity: 0.95
            font.family: root.headFont
            font.weight: Font.Bold
            font.pixelSize: root.u * 6.4
            font.letterSpacing: root.u * 0.5
        }
        Text {
            visible: !root.clock24h
            x: root.width / 2 + timeText.contentWidth / 2 + root.u * 0.8
            y: root.u * 1.3
            text: Qt.formatTime(root.now, "AP").toUpperCase()
            color: root.secondary
            opacity: 0.9
            font.family: root.headFont
            font.weight: Font.DemiBold
            font.pixelSize: root.u * 1.7
            font.letterSpacing: root.u * 0.25
        }
        Text {
            y: root.u * 7.2
            width: root.width
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(root.now, "dddd d MMMM").toUpperCase()
            color: "#e8e6d9"
            opacity: 0.6
            font.family: root.monoFont
            font.pixelSize: root.u * 1.2
            font.letterSpacing: root.u * 0.5
        }
    }
    Timer {
        running: root.showClock
        repeat: true
        interval: 1000
        onTriggered: {
            root.now = new Date();
            interval = 60000 - (root.now.getSeconds() * 1000 + root.now.getMilliseconds()) + 50;
        }
    }

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
    Bracket { atTop: false; atLeft: true;  x: root.u * 1.4; y: root.height - root.insetPx - height - root.u * 1.4 }
    Bracket { atTop: false; atLeft: false; x: root.width - width - root.u * 1.4; y: root.height - root.insetPx - height - root.u * 1.4 }

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

    Canvas {
        anchors.fill: parent
        onPaint: {
            var c = getContext("2d");
            c.reset();
            c.fillStyle = "rgba(0,0,0,0.18)";
            for (var y = 0; y < height; y += 3) c.fillRect(0, y, width, 1);
        }
    }
}
