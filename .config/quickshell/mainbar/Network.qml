import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs as Root

Rectangle {
    id: netContainer
    width: 44
    height: 30
    color: Root.Colors.bgMain
    radius: 12

    property string netType: ""
    property string netName: "..."
    property string iconFont: "JetBrainsMono Nerd Font"

    visible: netType !== ""

    Column {
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: netType === "lan" ? "󰌘" : (netType === "wifi" ? "" : "")
            font.family: iconFont
            font.pixelSize: 18
            color: netType !== "lan" && netType !== "wifi" ? Root.Colors.grayText : Root.Colors.mainIcon
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: netType === "wifi" ? Qt.PointingHandCursor : Qt.ArrowCursor

        onEntered: {
            netNameProc.running = false
            netNameProc.running = true
            tooltip.visible = true
        }
        onExited: tooltip.visible = false

        // Dispara nmtui si el tipo de red es wifi
        onClicked: {
            if (netType === "wifi") {
                wifiManagerProc.running = false
                wifiManagerProc.running = true
            }
        }
    }

    // --- TOOLTIP ---
    PopupWindow {
        id: tooltip
        visible: false
        height: 30
        width: 200
	color: "transparent"

        anchor {
            item: netContainer
            edges: Edges.Top
            rect.y: 0
            rect.x: 45
        }

        Rectangle {
            width: textLabel.contentWidth + 16
            height: 30
            color: Root.Colors.bgModules
            radius: 6

            Text {
                id: textLabel
                text: netName
                color: Root.Colors.whiteText
                font.pixelSize: 11
                font.bold: true
                anchors.centerIn: parent
            }
        }
    }

    // --- PROCESO PARA ABRIR NMTUI ---
    Process {
        id: wifiManagerProc
        command: ["foot", "--title", "nmtui", "-e", "nmtui"]
    }

    // --- PROCESOS DE DETECCIÓN Y RED ---
    Process {
        id: netProc
        command: ["sh", "-c", "ip route | awk '/default/ {print $5; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (out.indexOf("en") === 0 || out.indexOf("eth") === 0) {
                    netType = "lan"
                } else if (out.indexOf("wl") === 0) {
                    netType = "wifi"
                } else {
                    netType = ""
                }
            }
        }
    }

    Process {
        id: netNameProc
        command: [
            "sh", "-c",
            netType === "wifi"
                ? "LC_ALL=C nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '\$1==\"yes\" {print \$2}'"
                : "ip route | awk '/default/ {print $5; exit}'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (out) {
                    netName = out
                } else {
                    netName = netType === "lan" ? "Cableado" : "Desconectado"
                }
            }
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            netProc.running = false
            netProc.running = true

            if (netType !== "") {
                netNameProc.running = false
                netNameProc.running = true
            }
        }
    }
}
