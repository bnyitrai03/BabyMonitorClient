import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    property real hysteresis: 10
    property bool lampIsOn: false

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
                width: Math.min(500, parent.width * 0.9)
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

                    Label { text: "️Temperature:"; font.bold: true; font.pixelSize: 16 }
                    Label { text: "Light Level:"; font.bold: true; font.pixelSize: 16 }

                    Label {
                        font.pixelSize: 16
                        text: sensorController.online ? "♨️ " + sensorController.tempValue.toFixed(1) + " °C" : "---"
                        color: sensorController.online ? "#34495e" : "gray"
                    }

                    Label {
                        font.pixelSize: 16
                        text: sensorController.online ? "💡 " + sensorController.luxValue.toFixed(0) + " lux" : "---"
                        color: sensorController.online ? "#34495e" : "gray"
                    }
                }

                // --- LUX THRESHOLD AND LAMP STATUS ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 400
                    height: 220
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        // Editable threshold input
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10

                            Label {
                                text: "Light Threshold:"
                                font.bold: true
                                font.pixelSize: 16
                                color: "#34495e"
                            }

                            Rectangle {
                                width: 100
                                height: 30
                                color: sensorController.online ? "white" : "#f0f0f0"
                                border.color: thresholdInput.activeFocus ? "#3498db" : "#bdc3c7"
                                border.width: 2
                                radius: 4

                                TextInput {
                                    id: thresholdInput
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    text: sensorController.online && sensorController.luxThreshold > 0 ?
                                          sensorController.luxThreshold.toString() : "---"
                                    font.pixelSize: 14
                                    color: sensorController.online ? "#2c3e50" : "gray"
                                    enabled: sensorController.online
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    validator: IntValidator { bottom: 0; top: 99999 }
                                    selectByMouse: true

                                    // Update the input when the controller value changes
                                    Connections {
                                        target: sensorController
                                        function onSensorDataChanged() {
                                            if (!thresholdInput.activeFocus && sensorController.online && sensorController.luxThreshold > 0) {
                                                thresholdInput.text = sensorController.luxThreshold.toString()
                                            }
                                        }
                                    }
                                }
                            }

                            // Update button
                            Button {
                                text: "Set"
                                enabled: sensorController.online && thresholdInput.text.length > 0
                                font.pixelSize: 12
                                background: Rectangle {
                                    color: parent.enabled ? (parent.pressed ? "#2980b9" : "#3498db") : "#bdc3c7"
                                    radius: 4
                                    border.color: Qt.darker(color, 1.2)
                                    border.width: 1
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? "white" : "gray"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font: parent.font
                                }

                                onClicked: {
                                    if (thresholdInput.text.length > 0) {
                                        var newThreshold = parseInt(thresholdInput.text)
                                        if (!isNaN(newThreshold) && newThreshold > 0) {
                                            sensorController.updateLuxThreshold(newThreshold)
                                        }
                                    }
                                }
                            }
                        }

                        // LED Brightness Control
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 15

                            Label {
                                text: "LED Brightness:"
                                font.bold: true
                                font.pixelSize: 16
                                color: "#34495e"
                            }

                            CustomSlider {
                                id: brightnessSlider
                                from: 0
                                to: 1
                                stepSize: 0.05
                                enabled: sensorController.online
                                //value: sensorController.online ? sensorController.ledBrightness : 0

                                onPressedChanged: {
                                    if (!pressed && sensorController.online) {
                                        sensorController.updateLedBrightness(value)
                                    }
                                }
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
                                color: sensorController.online && lampIsOn ? "#f39c12" : "#95a5a6"
                                border.color: Qt.darker(color, 1.3)
                                border.width: 2

                                // Lamp bulb icon
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: lampIsOn ? "#fff" : "#7f8c8d"
                                    border.color: lampIsOn ? "#e67e22" : "#95a5a6"
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
                                                color: lampIsOn ? "#e67e22" : "#7f8c8d"
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
                                    opacity: lampIsOn ? 0.3 : 0
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
                                        return lampIsOn ? "ON" : "OFF"
                                    }
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: {
                                        if (!sensorController.online) return "gray"
                                        if (sensorController.luxThreshold < 0) return "#e67e22"
                                        return lampIsOn ? "#27ae60" : "#c0392b"
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

    // Hysteresis implementation, update lampIsOn based on sensor data
    Connections {
        target: sensorController

        function onSensorDataChanged() {
            if (!sensorController.online || sensorController.luxThreshold < 0)
                return

            const lux = sensorController.luxValue
            const threshold = sensorController.luxThreshold

            if (lampIsOn) {
                if (lux > threshold + hysteresis) {
                    lampIsOn = false
                }
            } else {
                if (lux < threshold) {
                    lampIsOn = true
                }
            }
        }
    }
}
