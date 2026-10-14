import QtQuick

// Concept 4: a quiet terminal in the corner plus a status block.
// Motion budget: the cursor blinks twice a second (2 fps); everything else is still.
Base {
    id: root

    property bool cursorOn: true

    readonly property var lines: [
        ["a", "link ................ established"],
        ["a", "handshake ........... complete"],
        ["s", "node 0x4F2A ......... secure"],
        ["a", "channel ............. encrypted"],
        ["s", "latency ............. 4 ms"],
        ["a", "session ............. awaiting credentials"]
    ]

    // log block, bottom left
    Item {
        x: root.u * 5
        y: root.height - root.insetPx - root.u * 17
        width: root.u * 34
        height: root.u * 13

        Rectangle { width: 2; height: parent.height; color: root.accent; opacity: 0.8 }

        Repeater {
            model: root.lines
            Text {
                required property int index
                required property var modelData
                x: root.u * 1.4
                y: index * root.u * 1.9
                textFormat: Text.StyledText
                color: "#b9b7a3"
                font.family: root.monoFont
                font.pixelSize: root.u * 1.15
                text: "<font color='" + (modelData[0] === "a" ? root.accent : root.secondary)
                      + "'>&gt;</font> " + modelData[1]
            }
        }
        Rectangle {
            x: root.u * 1.4
            y: root.lines.length * root.u * 1.9 + root.u * 0.2
            width: root.u * 0.65; height: root.u * 1.3
            color: root.accent
            opacity: root.cursorOn ? 1 : 0
        }
    }

    // status block, top right under the bracket
    Column {
        x: root.width - root.u * 22
        y: root.u * 6
        spacing: root.u * 0.5
        Repeater {
            model: [["NODE", "0x4F2A"], ["ZONE", "NIGHT CITY // 07"], ["CHANNEL", "ENCRYPTED"], ["STATE", "LOCKED"]]
            Row {
                required property var modelData
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
                    text: modelData[1]
                    color: "#e8e6d9"; opacity: 0.8
                    font.family: root.monoFont
                    font.pixelSize: root.u * 0.95
                    font.letterSpacing: root.u * 0.12
                }
            }
        }
    }

    Timer {
        interval: 500; repeat: true; running: true
        onTriggered: root.cursorOn = !root.cursorOn
    }
}
