import QtQuick
import org.kde.plasma.plasmoid

// Loads the design chosen for this screen (Style in the wallpaper settings) and
// feeds it the stamped colors, title and fonts. Each screen and the lock screen
// have their own settings, so each can use a different design.
WallpaperItem {
    id: root

    SystemInfo { id: sys }

    // bundled fonts from the splash theme; system fonts if they are missing
    readonly property string fontDir: "file:///usr/share/plasma/look-and-feel/org.cyberpunk.splash/contents/splash/fonts/"
    FontLoader { id: fBold; source: root.fontDir + "Rajdhani-Bold.ttf" }
    FontLoader { id: fMono; source: root.fontDir + "ShareTechMono-Regular.ttf" }
    FontLoader { source: root.fontDir + "Rajdhani-SemiBold.ttf" }
    // Title and tagline alternates, shipped inside the plugin itself so they work
    // even when the splash theme on the system is older. Registered so a font
    // setting can name them.
    FontLoader { source: Qt.resolvedUrl("../fonts/Oxanium-ExtraBold.ttf") }
    FontLoader { source: Qt.resolvedUrl("../fonts/ChakraPetch-Bold.ttf") }
    FontLoader { source: Qt.resolvedUrl("../fonts/Tektur-Bold.ttf") }

    Loader {
        id: design
        anchors.fill: parent
        source: "designs/" + root.configuration.Style + ".qml"
    }

    // Per-screen values from the settings page win; empty, 0 or -1 mean "not set",
    // and then the system config (the stamped SystemInfo) is used.
    readonly property var cfg: root.configuration
    readonly property string effAccent: cfg.Accent !== "" ? cfg.Accent : sys.accent
    readonly property string effSecondary: cfg.Secondary !== "" ? cfg.Secondary : sys.secondary
    readonly property string effTitle: cfg.Title !== "" ? cfg.Title : sys.title
    readonly property string effTagline: cfg.Tagline !== "" ? cfg.Tagline : sys.tagline
    readonly property real effTitleY: cfg.TitleY >= 0 ? cfg.TitleY / 100 : sys.titleY
    readonly property string effTitleFont: cfg.TitleFont !== "" ? cfg.TitleFont : sys.titleFont
    readonly property string effTaglineFont: cfg.TaglineFont !== "" ? cfg.TaglineFont : sys.taglineFont
    readonly property real effTitleScale: cfg.TitleScale > 0 ? cfg.TitleScale / 100 : sys.titleScale
    readonly property string effCaseSensor: cfg.CaseSensor !== "" ? cfg.CaseSensor : sys.caseSensor
    readonly property string effLogItems: cfg.LogItems !== "" ? cfg.LogItems : sys.logItems
    readonly property int effLogRefresh: cfg.LogRefresh > 0 ? cfg.LogRefresh : sys.logRefresh
    readonly property int effSparkStep: cfg.SparkStep > 0 ? cfg.SparkStep : (cfg.LogRefresh > 0 ? cfg.LogRefresh : sys.sparkStep)
    readonly property string effSparkScale: cfg.SparkScale !== "" ? cfg.SparkScale : sys.sparkScale
    readonly property int effSparkPoints: cfg.SparkPoints > 0 ? cfg.SparkPoints : sys.sparkPoints

    // Classic builds everything from SystemInfo itself; the others (built on Base,
    // which has titleY) take properties
    readonly property bool takesProps: design.status === Loader.Ready && design.item.titleY !== undefined
    readonly property bool hasLog: takesProps && design.item.logItems !== undefined
    Binding { target: design.item; property: "accent"; value: root.effAccent; when: root.takesProps }
    Binding { target: design.item; property: "secondary"; value: root.effSecondary; when: root.takesProps }
    Binding { target: design.item; property: "title"; value: root.effTitle; when: root.takesProps }
    Binding { target: design.item; property: "tagline"; value: root.effTagline; when: root.takesProps }
    Binding { target: design.item; property: "titleY"; value: root.effTitleY; when: root.takesProps }
    Binding { target: design.item; property: "showTitle"; value: sys.showTitle; when: root.takesProps }
    Binding { target: design.item; property: "bottomInset"; value: root.configuration.BottomInset / 100; when: root.takesProps }
    Binding { target: design.item; property: "titleFont"; value: root.effTitleFont; when: root.takesProps }
    Binding { target: design.item; property: "taglineFont"; value: root.effTaglineFont; when: root.takesProps }
    Binding { target: design.item; property: "titleScale"; value: root.effTitleScale; when: root.takesProps }
    Binding { target: design.item; property: "showClock"; value: root.configuration.ShowClock; when: root.takesProps }
    Binding { target: design.item; property: "clock24h"; value: root.configuration.Clock24h; when: root.takesProps }
    Binding {
        target: design.item; property: "headFont"
        value: fBold.status === FontLoader.Ready ? fBold.name : "Noto Sans"
        when: root.takesProps
    }
    Binding {
        target: design.item; property: "monoFont"
        value: fMono.status === FontLoader.Ready ? fMono.name : "monospace"
        when: root.takesProps
    }
    Binding { target: design.item; property: "caseSensor"; value: root.effCaseSensor; when: root.hasLog }
    Binding { target: design.item; property: "logItems"; value: root.effLogItems; when: root.hasLog }
    Binding { target: design.item; property: "logRefresh"; value: root.effLogRefresh; when: root.hasLog }
    Binding { target: design.item; property: "sparkStep"; value: root.effSparkStep; when: root.hasLog }
    Binding { target: design.item; property: "sparkPoints"; value: root.effSparkPoints; when: root.hasLog }
    Binding { target: design.item; property: "sparkScale"; value: root.effSparkScale; when: root.hasLog }
}
