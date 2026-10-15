import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

// The facts for the identity block and the log: hostname, OS, kernel, CPU model and the Plasma
// and Qt versions. Read once from a few harmless commands (uname, /etc/os-release,
// /proc/cpuinfo and the package database); nothing is sent anywhere. Where a command is not
// allowed, for example in a locked-down greeter, the value stays empty and its row is hidden.
Item {
    id: facts

    property string hostname: ""
    property string kernel: ""
    property string osName: ""
    property string cpuModel: ""
    property string plasma: ""
    property string qt: ""

    // letters, digits and a few punctuation marks only
    function clean(s) { return (s || "").replace(/[^A-Za-z0-9 ._+:\/-]/g, "").substring(0, 48).trim(); }
    function version(line) {                       // "pkgname 6.7.5-1" -> "6.7.5"
        var v = (line.split(" ")[1] || "").split("-")[0];
        return clean(v.indexOf(":") >= 0 ? v.substring(v.indexOf(":") + 1) : v);
    }
    function parse(text) {
        var l = (text || "").split("\n");
        hostname = clean(l[0]);
        kernel = clean(l[1]);
        osName = clean((l[2] || "").replace(/"/g, ""));
        cpuModel = clean((l[3] || "").replace(/\([A-Za-z]*\)/g, "").replace(/ CPU/, "").replace(/ @.*/, "")
                         .replace(/^[0-9]+[a-z]* Gen /, "").replace(/^Intel /, "").replace(/^AMD /, "").replace(/ +/g, " "));
        for (var i = 4; i < l.length; i++) {
            if (l[i].indexOf("plasma-workspace ") === 0) plasma = version(l[i]);
            else if (l[i].indexOf("qt6-base ") === 0) qt = version(l[i]);
        }
    }

    Plasma5Support.DataSource {
        engine: "executable"
        connectedSources: ["uname -n; uname -r; sed -n 's/^PRETTY_NAME=//p' /etc/os-release; sed -n 's/^model name[^:]*: *//p' /proc/cpuinfo | head -n1; pacman -Q plasma-workspace qt6-base 2>/dev/null"]
        onNewData: (source, data) => { facts.parse(data["stdout"]); disconnectSource(source) }
    }
}
