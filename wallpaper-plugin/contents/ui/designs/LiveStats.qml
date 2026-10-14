import QtQuick
import org.kde.ksysguard.sensors as Sensors

// Live system readings from KDE's system monitor service (the same source the
// System Monitor widgets use). Loaded on demand by designs that show stats, so
// a missing service or module leaves the design running without them.
// Only plain numbers are read: usage, temperature, memory, uptime and GPU load.
Item {
    id: stats

    property int interval: 2000     // milliseconds between updates
    // Sensor ids to use instead of the built-in ones, by reading name: cpu, cputemp,
    // memused, memtotal, gpu, gputemp, vramused, vramtotal, uptime and case. A
    // missing or empty entry keeps the default; "case" has no default (no line).
    property var ids: ({})
    function pick(name, fallback) {
        var v = ids[name];
        return v !== undefined && v !== "" ? v : fallback;
    }

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
    // GPU panel: clock in MHz, power in watts, fan in rpm, junction temperature in C
    readonly property string gpuNameText: gpuName_.value !== undefined && gpuName_.value !== null ? String(gpuName_.value) : ""
    readonly property real gpuClock: num(gpuClock_.value)
    // CPU panel: average clock in MHz and the hottest core in C
    readonly property real cpuClock: num(cpuClock_.value)
    readonly property real cpuHot: num(cpuHot_.value)
    readonly property real gpuPower: num(gpuPower_.value)
    readonly property real gpuFan: num(gpuFan_.value)
    readonly property real gpuJunction: num(gpuJunction_.value)

    Sensors.Sensor { id: cpuUsage;   sensorId: stats.pick("cpu", "cpu/all/usage");                 updateRateLimit: stats.interval }
    Sensors.Sensor { id: cpuTemp;    sensorId: stats.pick("cputemp", "cpu/all/averageTemperature");    updateRateLimit: stats.interval }
    Sensors.Sensor { id: memUsed_;   sensorId: stats.pick("memused", "memory/physical/used");          updateRateLimit: stats.interval }
    Sensors.Sensor { id: memTotal_;  sensorId: stats.pick("memtotal", "memory/physical/total");         updateRateLimit: stats.interval }
    Sensors.Sensor { id: gpuUsage;   sensorId: stats.pick("gpu", "gpu/gpu0/usage");                updateRateLimit: stats.interval }
    Sensors.Sensor { id: gpuTemp_;   sensorId: stats.pick("gputemp", "gpu/gpu0/temperature");          updateRateLimit: stats.interval }
    Sensors.Sensor { id: vramUsed_;  sensorId: stats.pick("vramused", "gpu/gpu0/usedVram");             updateRateLimit: stats.interval }
    Sensors.Sensor { id: vramTotal_; sensorId: stats.pick("vramtotal", "gpu/gpu0/totalVram");            updateRateLimit: stats.interval }
    Sensors.Sensor { id: cpuClock_;    sensorId: "cpu/all/averageFrequency";   updateRateLimit: stats.interval }
    Sensors.Sensor { id: cpuHot_;      sensorId: "cpu/all/maximumTemperature"; updateRateLimit: stats.interval }
    Sensors.Sensor { id: gpuName_;     sensorId: stats.pick("gpuname", "gpu/gpu0/name");           updateRateLimit: 60000 }
    Sensors.Sensor { id: gpuClock_;    sensorId: stats.pick("gpuclock", "gpu/gpu0/coreFrequency"); updateRateLimit: stats.interval }
    Sensors.Sensor { id: gpuPower_;    sensorId: stats.pick("gpupower", "gpu/gpu0/power1");        updateRateLimit: stats.interval }
    Sensors.Sensor { id: gpuFan_;      sensorId: stats.pick("gpufan", "gpu/gpu0/fan1");            updateRateLimit: stats.interval }
    Sensors.Sensor { id: gpuJunction_; sensorId: stats.pick("gpujunction", "gpu/gpu0/temp2");      updateRateLimit: stats.interval }
    Sensors.Sensor {
        id: caseSensor
        sensorId: stats.pick("case", "")
        enabled: stats.pick("case", "") !== ""
        updateRateLimit: stats.interval
    }
    Sensors.Sensor { id: uptime_;    sensorId: stats.pick("uptime", "os/system/uptime");              updateRateLimit: 30000 }
}
