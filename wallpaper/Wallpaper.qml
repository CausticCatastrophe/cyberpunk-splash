import QtQuick

// Login-screen wallpaper in the style of the splash. Rendered to a PNG by
// render-wallpaper; the login box sits over the clear middle of the image.
Rectangle {
    id: root
    color: "#050506"

    property color accent: "#fcee09"
    property color secondary: "#02d7f2"
    property string title: "CYBERPUNK"
    property string tagline: "OS // neural desktop"
    property string titleFont: ""
    property real titleScale: 1.0
    property string taglineFont: ""
    readonly property string titleFamily:
        titleFont !== "" && Qt.fontFamilies().indexOf(titleFont) >= 0 ? titleFont : headFont
    readonly property string taglineFamily:
        taglineFont !== "" && Qt.fontFamilies().indexOf(taglineFont) >= 0 ? taglineFont : headFont
    property real titleY: 0.40      // title top, as a fraction of the height
    property bool showTitle: true
    property string headFont: "Rajdhani"
    property string monoFont: "Share Tech Mono"

    readonly property real u: width / 100   // 1 unit = 1% of width

    // faint grid
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

    // soft accent glow rising from the bottom edge
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

    // title and tagline, kept quiet so the login box stays readable.
    // A secondary-colored ghost sits just behind the title, like the splash's glitch.
    Text {
        x: root.u * 19.7
        y: root.height * root.titleY
        width: root.u * 60
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.HorizontalFit    // a wide font shrinks to fit between the side columns
        minimumPixelSize: 8
        text: root.title
        visible: root.showTitle
        color: root.secondary
        opacity: 0.22
        font.family: root.titleFamily
        font.weight: Font.Bold
        font.pixelSize: root.u * 11 * root.titleScale
        font.letterSpacing: root.u * 0.7 * root.titleScale
    }
    Text {
        id: mainTitle
        x: root.u * 20
        y: root.height * root.titleY
        width: root.u * 60
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.HorizontalFit
        minimumPixelSize: 8
        // how much it had to shrink (1 = not at all); the tagline follows it up
        readonly property real fit: fontInfo.pixelSize > 0
            ? Math.min(1, fontInfo.pixelSize / (root.u * 11 * root.titleScale)) : 1
        text: root.title
        visible: root.showTitle
        color: "#e8e6d9"
        opacity: 0.65
        font.family: root.titleFamily
        font.weight: Font.Bold
        font.pixelSize: root.u * 11 * root.titleScale
        font.letterSpacing: root.u * 0.7 * root.titleScale
    }
    Text {
        y: root.height * root.titleY + root.u * 11.6 * root.titleScale * mainTitle.fit
        width: root.width
        horizontalAlignment: Text.AlignHCenter
        text: root.tagline.toUpperCase()
        visible: root.showTitle
        color: root.accent
        opacity: 0.75
        font.family: root.taglineFamily
        font.weight: Font.DemiBold
        font.pixelSize: root.u * 1.4
        font.letterSpacing: root.u * 0.84
    }

    // thin rules above and below the middle
    Rectangle { x: root.u * 30; width: root.u * 40; y: root.height * 0.88; height: 1; color: root.accent; opacity: 0.35 }
    Text {
        y: root.height * 0.88 + root.u * 0.8
        width: root.width
        horizontalAlignment: Text.AlignHCenter
        text: "AUTHENTICATION REQUIRED"
        color: root.accent
        opacity: 0.55
        font.family: root.monoFont
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

    // vignette: darken the edges so the center stays calm
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

    // scanlines
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
