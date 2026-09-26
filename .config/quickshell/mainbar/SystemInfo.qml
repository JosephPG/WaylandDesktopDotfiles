import QtQuick
import Quickshell
import Quickshell.Io
import qs as Root

Rectangle {
    id: systemContainer
    width: 44
    height: 160
    color: Root.Colors.bgMain
    radius: 12

    property string cpuUsage: "0"
    property string ramUsage: "0"
    property string batLevel: "0"

    // Definimos el nombre de la fuente de íconos globalmente
    property string iconFont: "JetBrainsMono Nerd Font"

    Column {
        anchors.centerIn: parent
        spacing: 16

        // --- SUBMÓDULO: BATERÍA ---
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2
            Text {
                text: ""
                font.family: iconFont
                font.pixelSize: 16
                color: Root.Colors.mainIcon
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: batLevel + "%"
                font.pixelSize: 8
                color: Root.Colors.whiteText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // --- SUBMÓDULO: CPU ---
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2
            Text {
                text: ""
                font.family: iconFont
                font.pixelSize: 16
                color: Root.Colors.mainIcon
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: cpuUsage + "%"
                font.pixelSize: 8
                color: Root.Colors.whiteText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // --- SUBMÓDULO: RAM ---
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2
            Text {
                text: ""
                font.family: iconFont
                font.pixelSize: 16
                color: Root.Colors.mainIcon
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: ramUsage + "%"
                font.pixelSize: 8
                color: Root.Colors.whiteText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // --- PROCESOS CON MANEJO DE PROPIEDAD CORRECTA ---
    Process {
        id: cpuProc
        command: ["sh", "-c", "awk '{print $1}' /proc/loadavg | awk '{print int($1 * 100 / 4)}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (out) cpuUsage = out
            }
        }
    }

    Process {
        id: ramProc
        command: ["sh", "-c", "awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2; print int((t-a)/t*100)}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (out) ramUsage = out
            }
        }
    }

    Process {
        id: batProc
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (out) batLevel = out
            }
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = false
            ramProc.running = false
            batProc.running = false

            cpuProc.running = true
            ramProc.running = true
            batProc.running = true
        }
    }
}
