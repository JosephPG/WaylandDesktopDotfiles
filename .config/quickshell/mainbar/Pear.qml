import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs as Root

Rectangle {
    id: mediaContainer
    width: 44
    height: 30
    color: Root.Colors.bgMain
    radius: 12

    // Propiedades de estado de la música
    property string playbackStatus: "" // "Playing", "Paused" o ""
    property string trackTitle: "Nada reproduciendo"
    property string iconFont: "JetBrainsMono Nerd Font"

    // El componente solo aparece si Pear Desktop está abierto o reproduciendo
    visible: playbackStatus !== ""

    Column {
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: playbackStatus === "Playing" ? "󰝚" : ""
            font.family: iconFont
            font.pixelSize: 18
            color: playbackStatus === "Playing" ? Root.Colors.mainIcon : Root.Colors.grayText 
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        id: containerMouseArea
        anchors.fill: parent
        // Desactivamos hoverEnabled ya que todo se controlará por clics
        hoverEnabled: false 
        
        // Clic izquierdo: Alterna la visibilidad del menú interactivo
        onClicked: {
            if (!tooltip.visible) {
                // Actualiza los metadatos inmediatamente antes de mostrarlo
                mediaMetaProc.running = false
                mediaMetaProc.running = true
                tooltip.visible = true
            } else {
                tooltip.visible = false
            }
        }
    }

    // --- DISPLAY FLOTANTE (MENÚ DE CANCIÓN CON BOTONES) ---
    PopupWindow {
        id: tooltip
        visible: false
        height: 200
        width: 300
        color: "transparent"

        // Retiene la interacción y se cierra al hacer clic fuera del menú
        grabFocus: true 

        anchor {
            item: mediaContainer
            edges: Edges.Top
            rect.y: -30
            rect.x: 45
        }

        Rectangle {
            width: 200
            height: 90
            color: Root.Colors.bgModules 
            radius: 8

            // Eliminamos el MouseArea de cierre por hover que causaba conflictos

            Column {
                anchors.centerIn: parent
                spacing: 12
		
		Item {
		    id: textClipContainer
		    width: 168
		    height: textLabel.height
		    clip: true // OCULTA EL TEXTO FLOTANTE EXTRA
		    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
			id: textLabel
			text: trackTitle
			color: Root.Colors.whiteText
			font.pixelSize: 11
			font.bold: true
			x: textLabel.contentWidth > textClipContainer.width ? 0 : (textClipContainer.width - textLabel.width) / 2

			// Animación de desplazamiento (Solo se activa si el texto es más largo que el contenedor)
			SequentialAnimation on x {
			    running: textLabel.contentWidth > textClipContainer.width
			    loops: Animation.Infinite

			    // Pausa al inicio de la canción
			    PauseAnimation { duration: 2000 }

			    // Se mueve hacia la izquierda revelando el final
			    NumberAnimation {
				to: -(textLabel.contentWidth - textClipContainer.width) 
				duration: Math.max(3000, textLabel.contentWidth * 20) // Velocidad dinámica
				easing.type: Easing.Linear
			    }

			    // Pausa al final antes de reiniciar
			    PauseAnimation { duration: 2000 }

			    // Regresa al inicio rápidamente
			    NumberAnimation {
				to: 0
				duration: 0
			    }
			}
                    }
		}

                // Fila de controles multimedia usando fuentes e íconos Nerd Font
                Row {
                    spacing: 24
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Botón Atrás
                    Text {
                        text: "󰒮"
                        font.family: iconFont
                        font.pixelSize: 18
                        color: backMouse.containsMouse ? Root.Colors.mainIcon : Root.Colors.whiteText
                        
                        MouseArea {
                            id: backMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                prevTrackProc.running = false
                                prevTrackProc.running = true
                            }
                        }
                    }

                    // Botón Play / Pause
                    Text {
                        text: playbackStatus === "Playing" ? "" : "" 
                        font.family: iconFont
                        font.pixelSize: 18
                        color: playMouse.containsMouse ? Root.Colors.mainIcon : Root.Colors.whiteText
                        
                        MouseArea {
                            id: playMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                togglePlayProc.running = false
                                togglePlayProc.running = true
                            }
                        }
                    }

                    // Botón Adelante
                    Text {
                        text: "󰒭"
                        font.family: iconFont
                        font.pixelSize: 18
                        color: nextMouse.containsMouse ? Root.Colors.mainIcon : Root.Colors.whiteText
                        
                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                nextTrackProc.running = false
                                nextTrackProc.running = true
                            }
                        }
                    }
                }
            }
        }
    }

    // --- PROCESOS MPRIS (PLAYERCTL) ---

    // 1. Detecta si Pear Desktop está activo y su estado de reproducción
    Process {
        id: mediaStatusProc
        command: ["playerctl", "-p", "chromium", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                playbackStatus = out 
            }
        }
    }

    // 2. Obtiene el título de la canción actual
    Process {
        id: mediaMetaProc
        command: ["playerctl", "-p", "chromium", "metadata", "--format",  "{{ title }} - {{ artist }}"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (out) {
                    trackTitle = out
                } else {
                    trackTitle = "YouTube Music"
                }
            }
        }
    }

    // 3. Proceso de un solo disparo para hacer Play/Pause al hacer clic
    Process {
        id: togglePlayProc
        command: ["playerctl", "-p", "chromium", "play-pause"]
    }

    // 4. Proceso para retroceder pista
    Process {
        id: prevTrackProc
        command: ["playerctl", "-p", "chromium", "previous"]
    }

    // 5. Proceso para avanzar pista
    Process {
        id: nextTrackProc
        command: ["playerctl", "-p", "chromium", "next"]
    }

    // Monitoreo continuo del estado de la música cada 2 segundos
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            mediaStatusProc.running = false
            mediaStatusProc.running = true
            
            if (playbackStatus !== "") {
                mediaMetaProc.running = false
                mediaMetaProc.running = true
            }
        }
    }
}
