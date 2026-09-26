import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs as Root

Rectangle {
    id: btContainer
    width: 44
    height: 30
    color: Root.Colors.bgMain //"#1e1e2e"
    radius: 12

    // Estados posibles: "connected" (conectado), "on" (encendido libre), "off" (apagado)
    property string btState: "off"
    property string btDeviceName: "..."
    property string iconFont: "JetBrainsMono Nerd Font"

    // Ahora SIEMPRE es visible para que puedas encenderlo desde la barra si está apagado
    visible: true

    Column {
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: btState === "connected" ? "󰂰" : (btState === "on" ? "󰂯" : "󰂲")
            font.family: iconFont
            font.pixelSize: 18
            color: btState === "connected" ?
		Root.Colors.mainIcon : (btState === "on" ? Root.Colors.mainIcon : Root.Colors.grayText)
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            btNameProc.running = false
            btNameProc.running = true
            tooltip.visible = true
        }
        onExited: tooltip.visible = false

        // --- ACCIÓN AL HACER CLICK ---
        onClicked: {
            btManagerProc.running = false
            btManagerProc.running = true
        }
    }

    // --- DISPLAY FLOTANTE (TOOLTIP) ---
    PopupWindow {
        id: tooltip
        visible: false
	width: 500
	height: 28
	color: "transparent"

        anchor {
            item: btContainer
            edges: Edges.Top
            rect.y: 0
            rect.x: 45
        }

        Rectangle {
            width: textLabel.contentWidth + 16
            height: 28
            color: Root.Colors.bgModules
            radius: 6

            Text {
                id: textLabel
                text: btDeviceName
                color: Root.Colors.whiteText
                font.pixelSize: 11
                font.bold: true
                anchors.centerIn: parent
            }
        }
    }

    // --- PROCESO PARA GESTIONAR CON BLUETOOTHCTL ---
    Process {
        id: btManagerProc
        command: ["foot", "--title", "bluetoothctl", "-e", "bluetoothctl"]
    }

    // --- PROCESOS DE MONITOREO MODIFICADOS ---

    // 1. Detecta si está apagado ("off"), encendido ("on") o conectado ("connected")
    Process {
        id: btStateProc
        command: ["sh", "-c", "if ! bluetoothctl show | grep -q 'Powered: yes'; then echo 'off'; elif bluetoothctl devices Paired | awk '{print $2}' | xargs -I {} bluetoothctl info {} | grep -q 'Connected: yes'; then echo 'connected'; else echo 'on'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                btState = out ? out : "off"
            }
        }
    }

    // 2. Obtiene el nombre del dispositivo conectado o el estado actual
    Process {
        id: btNameProc
        command: ["sh", "-c", "if [ \"" + btState + "\" = \"off\" ]; then echo 'Apagado'; elif [ \"" + btState + "\" = \"connected\" ]; then bluetoothctl devices Paired | awk '{print $2}' | xargs -I {} bluetoothctl info {} | grep -B 10 'Connected: yes' | awk -F: '/Name:/ {print $2; exit}' | xargs; else echo 'Sin conexiones'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (out) {
                    btDeviceName = out
                } else {
                    btDeviceName = btState === "off" ? "Bluetooth Apagado" : "Bluetooth Activo"
                }
            }
        }
    }

    // Actualización regular cada 4 segundos
    Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            btStateProc.running = false
            btStateProc.running = true
            btNameProc.running = false
            btNameProc.running = true
        }
    }
}
