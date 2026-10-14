import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

// Reads the JSON files that providers write to $XDG_STATE_HOME/ai-usage, one line each
// (see usage/README.md). Local files only: no network, no credentials. Loaded only when
// the usage block is switched on.
Item {
    id: data

    // [{ provider, updated (epoch s), windows: [{ label, used (0-100), resets_at (epoch s) }] }]
    property var providers: []
    property real now: Date.now()

    function parse(text) {
        var out = [], lines = (text || "").split("\n");
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].trim() === "") continue;
            try {
                var p = JSON.parse(lines[i]);
                if (p.provider && p.windows && p.windows.length > 0) out.push(p);
            } catch (e) { }
        }
        providers = out;
    }
    function timeLeft(sec) {
        var m = Math.max(0, Math.round((sec * 1000 - now) / 60000));
        var d = Math.floor(m / 1440), h = Math.floor(m % 1440 / 60);
        if (d > 0) return d + "d " + h + "h";
        return h > 0 ? h + "h " + (m % 60) + "m" : m + "m";
    }
    function clock(sec) { return Qt.formatTime(new Date(sec * 1000), "HH:mm"); }

    Plasma5Support.DataSource {
        engine: "executable"
        interval: 15000
        connectedSources: ["for f in \"${XDG_STATE_HOME:-$HOME/.local/state}\"/ai-usage/*.json; do [ -f \"$f\" ] && cat \"$f\"; done"]
        onNewData: (source, data2) => data.parse(data2["stdout"])
    }
    // refreshes countdowns and dimming without re-reading the files
    Timer {
        interval: 30000; repeat: true; running: true
        onTriggered: data.now = Date.now()
    }
}
