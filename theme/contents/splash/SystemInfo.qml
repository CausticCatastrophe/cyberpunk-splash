import QtQuick

// Default values. cyberpunk-splash-stamp overwrites this file on package
// changes; if it is ever missing or stale the splash still renders.
QtObject {
    readonly property string title: "CYBERPUNK"
    readonly property string tagline: "OS // neural desktop"
    readonly property string accent: "#fcee09"
    readonly property string secondary: "#02d7f2"
    readonly property bool glitchTitle: true
    readonly property bool crtTear: true
    readonly property bool crtRoll: true
    readonly property bool crtFlicker: true
    readonly property bool scanlines: true
    readonly property string userName: ""
    readonly property string osName: "Linux"
    readonly property string osVersion: ""
    readonly property string kernel: ""
    readonly property string hostname: ""
    readonly property string plasma: ""
}
