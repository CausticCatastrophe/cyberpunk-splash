import QtQuick

// Default values. cyberpunk-splash-stamp overwrites this file when the package is
// installed; these defaults are used when it has not run.
QtObject {
    readonly property string title: "CYBERPUNK"
    readonly property string tagline: "OS // neural desktop"
    readonly property string titleFont: ""
    readonly property string taglineFont: ""
    readonly property real titleScale: 1.0
    readonly property string accent: "#fcee09"
    readonly property string secondary: "#02d7f2"
    readonly property real titleY: 0.40
    readonly property bool showTitle: true
    readonly property bool glitchTitle: true
    readonly property bool crtTear: true
    readonly property bool crtRoll: true
    readonly property bool crtFlicker: true
    readonly property bool scanlines: true

    // facts for the log and identity block
    readonly property string osName: ""
    readonly property string kernel: ""
    readonly property string plasma: ""
    readonly property string qt: ""
    readonly property string hostname: ""
    readonly property string logItems: "cpu,cputemp,mem,gpu,gputemp,vram,case,uptime"
    readonly property int logRefresh: 1     // seconds between sensor readings
    readonly property int sparkStep: 1      // seconds between sparkline points
    readonly property int sparkPoints: 60   // points kept per sparkline (60 s at 1 s, like the widgets)
    readonly property string sparkScale: "auto"
    readonly property string caseSensor: ""   // sensor id of the case temperature, empty = none
    readonly property bool sparkSmooth: true
}
