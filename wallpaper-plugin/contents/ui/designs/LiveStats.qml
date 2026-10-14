import QtQuick
import org.kde.ksysguard.sensors as Sensors

// Live system readings from KDE's system monitor service (the same source the
// System Monitor widgets use). Loaded on demand by designs that show stats, so
// a missing service or module leaves the design running without them.
// Only plain numbers are read: usage, temperature, memory, uptime and GPU load.
Item {
    id: stats

    property int interval: 2000     // milliseconds between updates
    property string caseSensorId: ""   // motherboard "case" temperature sensor; empty = none

    // a sensor has no value until its first reading; NaN means "not yet"
    function num(v) { return v === undefined || v === null ? NaN : Number(v); }

    readonly property real cpu: num(cpuUsage.value)
    readonly property real temp: num(cpuTemp.value)
    readonly property real memUsed: num(memUsed_.value)
    readonly property real memTotal: num(memTotal_.value)
    readonly property real gpu: num(gpuUsage.value)
    readonly property real gpuTemp: num(gpuTemp_.value)
    readonly property real vramUsed: num(vramUsed_.value)
    readonly property real vramTotal: num(vramTotal_.value)
    readonly property real uptime: num(uptime_.value)
    readonly property real caseTemp: num(caseSensor.value)

    Sensors.Sensor { id: cpuUsage;   sensorId: "cpu/all/usage";                 updateRateLimit: stats.interval }
    Sensors.Sensor { id: cpuTemp;    sensorId: "cpu/all/averageTemperature";    updateRateLimit: stats.interval }
    Sensors.Sensor { id: memUsed_;   sensorId: "memory/physical/used";          updateRateLimit: stats.interval }
    Sensors.Sensor { id: memTotal_;  sensorId: "memory/physical/total";         updateRateLimit: stats.interval }
    Sensors.Sensor { id: gpuUsage;   sensorId: "gpu/gpu0/usage";                updateRateLimit: stats.interval }
    Sensors.Sensor { id: gpuTemp_;   sensorId: "gpu/gpu0/temperature";          updateRateLimit: stats.interval }
    Sensors.Sensor { id: vramUsed_;  sensorId: "gpu/gpu0/usedVram";             updateRateLimit: stats.interval }
    Sensors.Sensor { id: vramTotal_; sensorId: "gpu/gpu0/totalVram";            updateRateLimit: stats.interval }
    Sensors.Sensor {
        id: caseSensor
        sensorId: stats.caseSensorId
        enabled: stats.caseSensorId !== ""
        updateRateLimit: stats.interval
    }
    Sensors.Sensor { id: uptime_;    sensorId: "os/system/uptime";              updateRateLimit: 30000 }
}
