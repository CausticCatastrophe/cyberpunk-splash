import QtQuick
import org.kde.ksysguard.sensors as Sensors

// A grid of tiles, one per CPU core; a tile glows brighter as its core gets busier.
// Each tile fills one cell of the background grid (the cell size is passed in), so
// the map lines up with the grid lines behind it. Core count comes from a sensor
// and each core has its own usage sensor, so it follows whatever the machine has.
// Loaded on demand like LiveStats.
Item {
    id: map

    property color accent: "#fcee09"
    property string monoFont: "monospace"
    property real u: 10                              // 1% of the screen width, in pixels
    property real cell: 40                           // size of one background grid cell, in pixels
    property real captionH: cell / 2                 // height of the caption row above the tiles
    property int interval: 1000                      // milliseconds between updates
    property string countSensor: "cpu/all/coreCount"
    property int columns: 6                          // tiles per row; the layout fits the gutter it sits in
    // The tiles fill the text column of the block they sit in: from contentX to contentX + contentW.
    // The caption lines up with the headers above and below. Vertically each tile still fills a
    // whole grid cell; horizontally the column is split evenly.
    property real contentX: 0
    property real contentW: cols * cell

    function num(v) { return v === undefined || v === null ? NaN : Number(v); }

    readonly property int count: {
        var n = Math.floor(num(countSensorItem.value));
        return isFinite(n) ? Math.max(0, Math.min(64, n)) : 0;
    }
    readonly property int cols: Math.max(1, Math.min(columns, count))
    readonly property int rowCount: count > 0 ? Math.ceil(count / cols) : 0
    readonly property real inset: u * 0.35           // keeps neighbouring tiles apart

    readonly property real gapX: u * 0.7
    readonly property real pitchX: (contentW + gapX) / cols
    // a half-cell caption row, then one whole cell per line of tiles
    width: contentX + contentW
    height: captionH + rowCount * cell
    visible: count > 0

    Sensors.Sensor { id: countSensorItem; sensorId: map.countSensor; updateRateLimit: 30000 }

    Text {
        id: caption
        x: map.contentX
        y: (map.captionH - height) / 2
        text: "CORES  " + map.count
        color: map.accent
        opacity: 0.55
        font.family: map.monoFont
        font.pixelSize: map.u * 0.95
        font.letterSpacing: map.u * 0.12
    }

    Repeater {
        model: map.count
        Item {
            id: cell
            required property int index
            readonly property real load: Math.max(0, Math.min(1, map.num(sensor.value) / 100))
            x: map.contentX + (index % map.cols) * map.pitchX
            y: map.captionH + Math.floor(index / map.cols) * map.cell + map.inset
            width: map.pitchX - map.gapX
            height: map.cell - 2 * map.inset

            Sensors.Sensor {
                id: sensor
                sensorId: "cpu/cpu" + cell.index + "/usage"
                updateRateLimit: map.interval
            }
            Rectangle {                       // the glow: brighter with load
                anchors.fill: parent
                color: map.accent
                opacity: isFinite(cell.load) ? 0.10 + 0.90 * cell.load : 0.10
            }
            Rectangle {                       // a fixed frame so idle cores stay visible
                anchors.fill: parent
                color: "transparent"
                border.color: map.accent
                border.width: 1
                opacity: 0.45
            }
        }
    }
}
