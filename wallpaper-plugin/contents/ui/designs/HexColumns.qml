import QtQuick

// Concept 3: columns of hex data down both sides, the middle left clear.
// Motion budget: one highlighted row steps once a second (1 fps).
Base {
    id: root

    property int hot: 0     // row currently highlighted

    // deterministic pseudo-random hex so the picture is stable between runs
    function hex(seed, n) {
        var s = seed, out = "";
        for (var i = 0; i < n; i++) {
            s = (s * 1103515245 + 12345) & 0x7fffffff;
            out += "0123456789ABCDEF".charAt((s >> 16) & 15);
        }
        return out;
    }

    readonly property int rows: 34
    readonly property real rowH: usableH * 0.9 / rows

    component Column: Item {
        id: col
        property int seed: 1
        property real fade: 1
        width: root.u * 8
        height: root.height
        Repeater {
            model: root.rows
            Text {
                required property int index
                x: 0
                y: root.usableH * 0.05 + index * root.rowH
                text: root.hex(col.seed * 131 + index * 17, 4) + " " + root.hex(col.seed * 7 + index * 31, 4)
                color: index === root.hot ? root.secondary : root.accent
                opacity: (index === root.hot ? 0.95 : 0.30) * col.fade
                font.family: root.monoFont
                font.pixelSize: root.rowH * 0.62
                font.letterSpacing: root.u * 0.08
            }
        }
    }

    // left band, brightest at the edge
    Column { x: root.u * 3;  seed: 3; fade: 1.0 }
    Column { x: root.u * 11; seed: 5; fade: 0.7 }
    Column { x: root.u * 19; seed: 8; fade: 0.45 }
    // right band, mirrored
    Column { x: root.width - root.u * 11; seed: 12; fade: 1.0 }
    Column { x: root.width - root.u * 19; seed: 14; fade: 0.7 }
    Column { x: root.width - root.u * 27; seed: 21; fade: 0.45 }

    Timer {
        interval: 1000; repeat: true; running: true
        onTriggered: root.hot = (root.hot + 1) % root.rows
    }
}
