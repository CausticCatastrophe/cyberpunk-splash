import QtQuick

// Built-in defaults for everything the settings page can override, plus the live system
// facts. Each screen's settings win over these; an empty text, 0 or -1 there means "use this".
Item {
    id: info
    visible: false
    width: 0
    height: 0

    readonly property string title: "CYBERPUNK"
    readonly property string tagline: "OS // neural desktop"
    readonly property string titleFont: ""
    readonly property string taglineFont: ""
    readonly property real titleScale: 1.0
    readonly property string accent: "#fcee09"
    readonly property string secondary: "#02d7f2"
    readonly property real titleY: 0.35
    readonly property bool showTitle: true
    readonly property real gridOpacity: 0.14   // grid line strength
    readonly property bool glitchTitle: true   // effects of the Classic design
    readonly property bool crtTear: true
    readonly property bool crtRoll: true
    readonly property bool crtFlicker: true
    readonly property bool scanlines: true

    // facts for the log and identity block, read live (see SystemFacts.qml)
    Loader { id: facts; source: "SystemFacts.qml" }
    readonly property string osName: facts.item ? facts.item.osName : ""
    readonly property string kernel: facts.item ? facts.item.kernel : ""
    readonly property string cpuModel: facts.item ? facts.item.cpuModel : ""
    readonly property string plasma: facts.item ? facts.item.plasma : ""
    readonly property string qt: facts.item ? facts.item.qt : ""
    readonly property string hostname: facts.item ? facts.item.hostname : ""
    readonly property string logItems: "cpu,cputemp,mem,gpu,gputemp,vram,case"
    readonly property int logRefresh: 1     // seconds between sensor readings
    readonly property int sparkStep: 1      // seconds between sparkline points
    readonly property int sparkPoints: 60   // points kept per sparkline (60 s at 1 s, like the widgets)
    readonly property string sparkScale: "auto"
    readonly property string caseSensor: ""   // sensor id of the case temperature, empty = none
    // sensor ids that replace the built-in ones; empty keeps the default
    readonly property string sensorCpu: ""
    readonly property string sensorCpuTemp: ""
    readonly property string sensorMemUsed: ""
    readonly property string sensorMemTotal: ""
    readonly property string sensorGpu: ""
    readonly property string sensorGpuTemp: ""
    readonly property string sensorVramUsed: ""
    readonly property string sensorVramTotal: ""
    readonly property string sensorUptime: ""
    readonly property string sensorGpuName: ""
    readonly property string sensorGpuClock: ""
    readonly property string sensorGpuPower: ""
    readonly property string sensorGpuFan: ""
    readonly property string sensorGpuJunction: ""
    readonly property string sensorCoreCount: ""
    readonly property bool gpuPanel: true     // the live GPU panel, top right
    readonly property bool coreMap: true      // the CPU core map, bottom left
    readonly property bool sparkSmooth: true
}
