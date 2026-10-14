import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import org.kde.ksysguard.faces as Faces

// Settings for one screen (or the lock screen). Anything left at "Default" uses
// the value from /etc/cyberpunk-splash.conf.
Kirigami.FormLayout {
    id: root
    twinFormLayouts: parentLayout

    property alias formLayout: root

    // the login settings page assigns these for every plugin; unused here
    property string cfg_PreviewImage
    property string cfg_PreviewImageDefault
    property string cfg_DarkLightScheduleState
    property string cfg_DarkLightScheduleStateDefault

    property string cfg_Style
    property string cfg_StyleDefault
    property bool cfg_ShowClock
    property bool cfg_ShowClockDefault
    property bool cfg_Clock24h
    property bool cfg_Clock24hDefault
    property string cfg_TitleFont
    property string cfg_TaglineFont
    property int cfg_TitleScale
    property string cfg_Title
    property string cfg_Tagline
    property int cfg_TitleY
    property int cfg_BottomInset
    property string cfg_Accent
    property string cfg_Secondary
    property string cfg_LogItems
    property string cfg_CaseSensor
    property string cfg_SensorCpu
    property string cfg_SensorCpuTemp
    property string cfg_SensorMemUsed
    property string cfg_SensorMemTotal
    property string cfg_SensorGpu
    property string cfg_SensorGpuTemp
    property string cfg_SensorVramUsed
    property string cfg_SensorVramTotal
    property string cfg_SensorUptime
    property string cfg_SensorGpuName
    property string cfg_SensorGpuClock
    property string cfg_SensorGpuPower
    property string cfg_SensorGpuFan
    property string cfg_SensorGpuJunction
    property string cfg_SensorCoreCount
    property bool cfg_ShowGpuPanel
    property bool cfg_ShowCoreMap
    property int cfg_GridOpacity
    property int cfg_LogRefresh
    property int cfg_SparkStep
    property int cfg_SparkPoints
    property string cfg_SparkScale

    // value is the design's file name; the label says what it costs to run
    readonly property var styles: [
        { value: "DataTerminal", text: "Data terminal (log and hex columns, almost free)" },
        { value: "HexColumns",   text: "Hex columns (almost free)" },
        { value: "Terminal",     text: "Terminal (almost free)" },
        { value: "Classic",      text: "Classic (full motion, uses noticeable GPU)" }
    ]

    // log lines in a fixed order; the system config can use any order
    readonly property var logChoices: [
        { value: "cpu",     text: "CPU usage" },
        { value: "cputemp", text: "CPU temperature" },
        { value: "mem",     text: "Memory" },
        { value: "gpu",     text: "GPU usage" },
        { value: "gputemp", text: "GPU temperature" },
        { value: "vram",    text: "Video memory" },
        { value: "case",    text: "Case temperature" },
        { value: "uptime",  text: "Uptime" },
        { value: "os",      text: "OS" },
        { value: "kernel",  text: "Kernel" },
        { value: "plasma",  text: "Plasma version" },
        { value: "qt",      text: "Qt version" },
        { value: "host",    text: "Host name" }
    ]
    readonly property string defaultLog: "cpu,cputemp,mem,gpu,gputemp,vram,case"

    // The fonts that ship with this theme come first, then every installed family.
    // Entries whose value starts with "__" are headings and cannot be picked.
    readonly property var bundledFonts: ["Oxanium", "Chakra Petch", "Tektur"]
    readonly property var fontChoices: {
        var out = [{ value: "", text: "Default (Rajdhani)" },
                   { value: "__h1", text: "Bundled with this theme" }];
        for (var i = 0; i < bundledFonts.length; i++)
            out.push({ value: bundledFonts[i], text: bundledFonts[i] });
        out.push({ value: "__h2", text: "All installed fonts" });
        var fams = Qt.fontFamilies();
        for (var j = 0; j < fams.length; j++)
            if (bundledFonts.indexOf(fams[j]) < 0) out.push({ value: fams[j], text: fams[j] });
        return out;
    }

    function logHas(name) { return cfg_LogItems.split(",").indexOf(name) >= 0; }
    function logToggle(name, on) {
        var have = cfg_LogItems === "" ? [] : cfg_LogItems.split(","), out = [];
        for (var i = 0; i < logChoices.length; i++) {
            var n = logChoices[i].value;
            if (n === name ? on : have.indexOf(n) >= 0) out.push(n);
        }
        cfg_LogItems = out.length > 0 ? out.join(",") : defaultLog;
    }
    // A font picker: a button showing the current font that opens a searchable list.
    // Bundled fonts are on top; entries starting with "__" are headings.
    component FontPicker: QQC2.Button {
        id: btn
        property string current: ""
        signal picked(string value)

        text: current === "" ? "Default (Rajdhani)" : current
        icon.name: "font-select-symbolic"

        // the choices that match the search, headings only when not searching
        function matching(q) {
            var out = [], needle = q.toLowerCase();
            for (var i = 0; i < root.fontChoices.length; i++) {
                var c = root.fontChoices[i];
                if (needle === "" || (c.value.indexOf("__") !== 0 && c.text.toLowerCase().indexOf(needle) >= 0))
                    out.push(c);
            }
            return out;
        }

        onClicked: { search.text = ""; pop.open(); search.forceActiveFocus(); }

        QQC2.Popup {
            id: pop
            parent: QQC2.Overlay.overlay
            anchors.centerIn: QQC2.Overlay.overlay
            width: Kirigami.Units.gridUnit * 22
            height: Math.min(QQC2.Overlay.overlay ? QQC2.Overlay.overlay.height * 0.8 : 500, Kirigami.Units.gridUnit * 28)
            modal: true
            focus: true
            padding: Kirigami.Units.smallSpacing
            closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside

            // open with the current font in view
            onOpened: {
                for (var i = 0; i < list.model.length; i++)
                    if (list.model[i].value === btn.current) { list.positionViewAtIndex(i, ListView.Center); break; }
            }

            contentItem: ColumnLayout {
                spacing: Kirigami.Units.smallSpacing
                QQC2.TextField {
                    id: search
                    Layout.fillWidth: true
                    placeholderText: "Search fonts"
                }
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: btn.matching(search.text)
                    QQC2.ScrollBar.vertical: QQC2.ScrollBar {}
                    delegate: QQC2.ItemDelegate {
                        required property var modelData
                        width: ListView.view.width
                        text: modelData.text
                        enabled: modelData.value.indexOf("__") !== 0
                        font.bold: !enabled
                        highlighted: enabled && modelData.value === btn.current
                        onClicked: { btn.picked(modelData.value); pop.close(); }
                    }
                }
            }
        }
    }
    // A sensor picker: KDE's own chooser, the one the System Monitor widgets use, which
    // lists the sensors on this machine. Empty means "use the default sensor".
    component SensorField: Faces.Choices {
        id: sf
        property string current: ""
        signal picked(string sensorId)
        supportsColors: false
        labelsEditable: false
        maxAllowedSensors: 1
        selected: sf.current !== "" ? [sf.current] : []
        onSelectedChanged: sf.picked(selected && selected.length > 0 ? selected[0] : "")
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 22
    }
    // a spin box where the lowest value reads "Default"
    component DefaultSpin: QQC2.SpinBox {
        property string unit: ""
        property int offValue: 0
        editable: false
        textFromValue: function (v) { return v === offValue ? "Default" : v + unit; }
    }

    // ---- look ----
    QQC2.ComboBox {
        id: styleBox
        Kirigami.FormData.label: "Style:"
        textRole: "text"
        valueRole: "value"
        model: root.styles
        onActivated: root.cfg_Style = currentValue
        Component.onCompleted: currentIndex = Math.max(0, indexOfValue(root.cfg_Style))
    }
    FontPicker {
        Kirigami.FormData.label: "Title font:"
        current: root.cfg_TitleFont
        onPicked: value => root.cfg_TitleFont = value
    }
    FontPicker {
        Kirigami.FormData.label: "Tagline font:"
        current: root.cfg_TaglineFont
        onPicked: value => root.cfg_TaglineFont = value
    }
    DefaultSpin {
        Kirigami.FormData.label: "Title size:"
        from: 0; to: 150; stepSize: 5
        unit: " %"
        value: root.cfg_TitleScale
        onValueModified: root.cfg_TitleScale = value
    }
    DefaultSpin {
        Kirigami.FormData.label: "Title position:"
        from: -1; to: 80; stepSize: 5
        offValue: -1
        unit: " % from top"
        value: root.cfg_TitleY
        onValueModified: root.cfg_TitleY = value
    }
    DefaultSpin {
        Kirigami.FormData.label: "Grid contrast:"
        from: -1; to: 40; stepSize: 2
        offValue: -1
        unit: " %"
        value: root.cfg_GridOpacity
        onValueModified: root.cfg_GridOpacity = value
    }
    QQC2.SpinBox {
        Kirigami.FormData.label: "Bottom margin:"
        from: 0; to: 25
        editable: false
        textFromValue: function (v) { return v === 0 ? "None" : v + " % of height"; }
        value: root.cfg_BottomInset
        onValueModified: root.cfg_BottomInset = value
    }
    QQC2.Label {
        text: "Raises the log and bottom corners so a panel does not cover them. About 4 to 5 % clears a typical taskbar."
        opacity: 0.7
        wrapMode: Text.WordWrap
        Layout.maximumWidth: Kirigami.Units.gridUnit * 22
    }
    QQC2.TextField {
        Kirigami.FormData.label: "Title text:"
        placeholderText: "Default"
        text: root.cfg_Title
        onTextEdited: root.cfg_Title = text
    }
    QQC2.TextField {
        Kirigami.FormData.label: "Tagline text:"
        placeholderText: "Default"
        text: root.cfg_Tagline
        onTextEdited: root.cfg_Tagline = text
    }

    // ---- colors ----
    RowLayout {
        Kirigami.FormData.label: "Accent color:"
        KQuickControls.ColorButton {
            showAlphaChannel: false
            color: root.cfg_Accent !== "" ? root.cfg_Accent : "#fcee09"
            onAccepted: color => root.cfg_Accent = color.toString()
        }
        QQC2.Label { text: root.cfg_Accent === "" ? "Default" : root.cfg_Accent; opacity: 0.7 }
        QQC2.Button {
            text: "Use default"
            visible: root.cfg_Accent !== ""
            onClicked: root.cfg_Accent = ""
        }
    }
    RowLayout {
        Kirigami.FormData.label: "Secondary color:"
        KQuickControls.ColorButton {
            showAlphaChannel: false
            color: root.cfg_Secondary !== "" ? root.cfg_Secondary : "#02d7f2"
            onAccepted: color => root.cfg_Secondary = color.toString()
        }
        QQC2.Label { text: root.cfg_Secondary === "" ? "Default" : root.cfg_Secondary; opacity: 0.7 }
        QQC2.Button {
            text: "Use default"
            visible: root.cfg_Secondary !== ""
            onClicked: root.cfg_Secondary = ""
        }
    }

    // ---- clock ----
    QQC2.CheckBox {
        Kirigami.FormData.label: "Clock:"
        text: "Show the clock"
        checked: root.cfg_ShowClock
        onToggled: root.cfg_ShowClock = checked
    }
    QQC2.CheckBox {
        text: "24-hour time"
        enabled: root.cfg_ShowClock
        checked: root.cfg_Clock24h
        onToggled: root.cfg_Clock24h = checked
    }

    // ---- readings (Data terminal) ----
    Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: "Readings (Data terminal)" }
    QQC2.CheckBox {
        Kirigami.FormData.label: "Panels:"
        text: "Show the GPU panel (top right)"
        checked: root.cfg_ShowGpuPanel
        onToggled: root.cfg_ShowGpuPanel = checked
    }
    QQC2.CheckBox {
        text: "Show the CPU core map (bottom left)"
        checked: root.cfg_ShowCoreMap
        onToggled: root.cfg_ShowCoreMap = checked
    }
    QQC2.CheckBox {
        Kirigami.FormData.label: "Log lines:"
        text: "Use the list from the system config"
        checked: root.cfg_LogItems === ""
        onToggled: root.cfg_LogItems = checked ? "" : root.defaultLog
    }
    GridLayout {
        columns: 2
        enabled: root.cfg_LogItems !== ""
        Repeater {
            model: root.logChoices
            QQC2.CheckBox {
                required property var modelData
                text: modelData.text
                checked: root.logHas(modelData.value)
                onToggled: root.logToggle(modelData.value, checked)
            }
        }
    }
    // ---- sensors ----
    Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: "Sensors" }
    QQC2.Label {
        text: "Choose which sensor feeds each reading. Click a field to browse the sensors on this machine. Leave it empty to use the default."
        opacity: 0.7
        wrapMode: Text.WordWrap
        Layout.maximumWidth: Kirigami.Units.gridUnit * 22
    }
    SensorField { Kirigami.FormData.label: "CPU usage:";        current: root.cfg_SensorCpu;       onPicked: sensorId => root.cfg_SensorCpu = sensorId }
    SensorField { Kirigami.FormData.label: "CPU temperature:";  current: root.cfg_SensorCpuTemp;   onPicked: sensorId => root.cfg_SensorCpuTemp = sensorId }
    SensorField { Kirigami.FormData.label: "Memory used:";      current: root.cfg_SensorMemUsed;   onPicked: sensorId => root.cfg_SensorMemUsed = sensorId }
    SensorField { Kirigami.FormData.label: "Memory total:";     current: root.cfg_SensorMemTotal;  onPicked: sensorId => root.cfg_SensorMemTotal = sensorId }
    SensorField { Kirigami.FormData.label: "GPU usage:";        current: root.cfg_SensorGpu;       onPicked: sensorId => root.cfg_SensorGpu = sensorId }
    SensorField { Kirigami.FormData.label: "GPU temperature:";  current: root.cfg_SensorGpuTemp;   onPicked: sensorId => root.cfg_SensorGpuTemp = sensorId }
    SensorField { Kirigami.FormData.label: "Video memory used:"; current: root.cfg_SensorVramUsed; onPicked: sensorId => root.cfg_SensorVramUsed = sensorId }
    SensorField { Kirigami.FormData.label: "Video memory total:"; current: root.cfg_SensorVramTotal; onPicked: sensorId => root.cfg_SensorVramTotal = sensorId }
    SensorField { Kirigami.FormData.label: "Case temperature:"; current: root.cfg_CaseSensor;      onPicked: sensorId => root.cfg_CaseSensor = sensorId }
    SensorField { Kirigami.FormData.label: "Uptime:";           current: root.cfg_SensorUptime;    onPicked: sensorId => root.cfg_SensorUptime = sensorId }
    SensorField { Kirigami.FormData.label: "GPU name:";         current: root.cfg_SensorGpuName;   onPicked: sensorId => root.cfg_SensorGpuName = sensorId }
    SensorField { Kirigami.FormData.label: "GPU clock:";        current: root.cfg_SensorGpuClock;  onPicked: sensorId => root.cfg_SensorGpuClock = sensorId }
    SensorField { Kirigami.FormData.label: "GPU power:";        current: root.cfg_SensorGpuPower;  onPicked: sensorId => root.cfg_SensorGpuPower = sensorId }
    SensorField { Kirigami.FormData.label: "GPU fan:";          current: root.cfg_SensorGpuFan;    onPicked: sensorId => root.cfg_SensorGpuFan = sensorId }
    SensorField { Kirigami.FormData.label: "GPU junction temperature:"; current: root.cfg_SensorGpuJunction; onPicked: sensorId => root.cfg_SensorGpuJunction = sensorId }
    SensorField { Kirigami.FormData.label: "CPU core count:";   current: root.cfg_SensorCoreCount; onPicked: sensorId => root.cfg_SensorCoreCount = sensorId }
    DefaultSpin {
        Kirigami.FormData.label: "Read every:"
        from: 0; to: 60
        unit: " s"
        value: root.cfg_LogRefresh
        onValueModified: root.cfg_LogRefresh = value
    }
    DefaultSpin {
        Kirigami.FormData.label: "Graph point every:"
        from: 0; to: 300
        unit: " s"
        value: root.cfg_SparkStep
        onValueModified: root.cfg_SparkStep = value
    }
    DefaultSpin {
        Kirigami.FormData.label: "Graph points kept:"
        from: 0; to: 120
        value: root.cfg_SparkPoints
        onValueModified: root.cfg_SparkPoints = value
    }
    QQC2.ComboBox {
        id: scaleBox
        Kirigami.FormData.label: "Graph range:"
        textRole: "text"
        valueRole: "value"
        model: [
            { value: "",      text: "Default" },
            { value: "auto",  text: "Auto: zoom to the data" },
            { value: "fixed", text: "Fixed: full range" }
        ]
        onActivated: root.cfg_SparkScale = currentValue
        Component.onCompleted: currentIndex = Math.max(0, indexOfValue(root.cfg_SparkScale))
    }
    QQC2.Label {
        Kirigami.FormData.label: "Graph covers:"
        readonly property int step: root.cfg_SparkStep > 0 ? root.cfg_SparkStep : (root.cfg_LogRefresh > 0 ? root.cfg_LogRefresh : 1)
        readonly property int pts: root.cfg_SparkPoints > 0 ? root.cfg_SparkPoints : 60
        text: step * pts + " seconds (with the default settings, if left at Default)"
        opacity: 0.7
        wrapMode: Text.WordWrap
    }

    onCfg_SparkScaleChanged: scaleBox.currentIndex = Math.max(0, scaleBox.indexOfValue(cfg_SparkScale))
    onCfg_StyleChanged: styleBox.currentIndex = Math.max(0, styleBox.indexOfValue(cfg_Style))
}
