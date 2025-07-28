// SensorView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true

        Item {
            width: parent.width
            height: Math.max(parent.height, columnLayout.implicitHeight)

            ColumnLayout {
                id: columnLayout
                anchors.centerIn: parent
                width: Math.min(500, parent.width * 0.9) // Limit max width and add responsive sizing
                spacing: 30

                // --- HEADER WITH ONLINE INDICATOR ---
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    Rectangle {
                        id: statusIndicatorCircle
                        width: 24
                        height: 24
                        radius: 12
                        anchors.verticalCenter: parent.verticalCenter
                        color: sensorController.online ? "#2ecc71" : "#e74c3c"
                        border.color: Qt.darker(color, 1.2)
                        border.width: 2
                    }

                    Label {
                        text: "Sensor Dashboard"
                        font.pixelSize: 28
                        font.bold: true
                        color: "#2c3e50"
                    }
                }

                // --- SENSOR READINGS ---
                GridLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 10

                    Label { text: "🌡️Temperature:"; font.bold: true; font.pixelSize: 16 }
                    Label { text: "💡Light Level:"; font.bold: true; font.pixelSize: 16 }

                    Label {
                        font.pixelSize: 16
                        text: sensorController.online ? sensorController.tempValue.toFixed(1) + " °C" : "---"
                        color: sensorController.online ? "#34495e" : "gray"
                    }

                    Label {
                        font.pixelSize: 16
                        text: sensorController.online ? sensorController.luxValue.toFixed(0) + " lux" : "---"
                        color: sensorController.online ? "#34495e" : "gray"
                    }
                }

                // --- LUX THRESHOLD AND LAMP STATUS ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 400
                    height: 120
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        // Threshold display
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10

                            Label {
                                text: "Lux Threshold:"
                                font.bold: true
                                font.pixelSize: 16
                                color: "#34495e"
                            }

                            Label {
                                text: sensorController.online && sensorController.luxThreshold >= 0 ?
                                      sensorController.luxThreshold + " lux" : "---"
                                font.pixelSize: 16
                                color: sensorController.online ? "#2c3e50" : "gray"
                                font.bold: true
                            }
                        }

                        // Lamp status with icon
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 15

                            // Lamp icon
                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: lampShouldBeOn ? "#f39c12" : "#95a5a6"
                                border.color: Qt.darker(color, 1.3)
                                border.width: 2

                                property bool lampShouldBeOn: sensorController.online &&
                                                            sensorController.luxValue < sensorController.luxThreshold

                                // Lamp bulb icon
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: parent.lampShouldBeOn ? "#fff" : "#7f8c8d"
                                    border.color: parent.lampShouldBeOn ? "#e67e22" : "#95a5a6"
                                    border.width: 1

                                    // Lamp filament lines
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 2

                                        Repeater {
                                            model: 3
                                            Rectangle {
                                                width: 8
                                                height: 1
                                                color: parent.parent.parent.lampShouldBeOn ? "#e67e22" : "#7f8c8d"
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }
                                }

                                // Glow effect when lamp is on
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width + 8
                                    height: parent.height + 8
                                    radius: (parent.width + 8) / 2
                                    color: "transparent"
                                    border.color: "#f39c12"
                                    border.width: 2
                                    opacity: parent.lampShouldBeOn ? 0.3 : 0
                                    visible: opacity > 0

                                    Behavior on opacity {
                                        NumberAnimation { duration: 300 }
                                    }
                                }
                            }

                            // Lamp status text
                            Column {
                                spacing: 5

                                Label {
                                    text: "Lamp Status"
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: "#34495e"
                                }

                                Label {
                                    text: {
                                        if (!sensorController.online) return "Offline"
                                        if (sensorController.luxThreshold < 0) return "No Threshold"
                                        return sensorController.luxValue < sensorController.luxThreshold ? "ON" : "OFF"
                                    }
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: {
                                        if (!sensorController.online) return "gray"
                                        if (sensorController.luxThreshold < 0) return "#e67e22"
                                        return sensorController.luxValue < sensorController.luxThreshold ? "#27ae60" : "#c0392b"
                                    }
                                }
                            }
                        }
                    }
                }

                // --- STATUS & TIMESTAMP ---
                Label {
                    text: "🕒Last Update: " + sensorController.timestamp
                    color: "gray"
                    font.italic: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                }
            }
        }
    }
}
