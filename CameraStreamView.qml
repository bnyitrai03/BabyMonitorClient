// CameraStreamView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import BabyMonitor 1.0

Rectangle {
    id: root
    color: "#f0f0f0"

    property bool isReadyToStream: cameraComboBox.currentIndex > -1 &&
                                  formatComboBox.currentIndex > -1 &&
                                  resolutionComboBox.currentIndex > -1 &&
                                  fpsComboBox.currentIndex > -1

    // --- Main Layout ---
    RowLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10

        // --- Left Panel: Controls ---
        Frame {
            id: controlPanel
            Layout.preferredWidth: 350
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 5

                // --- Device Selector Section ---
                Label {
                    text: "Device Selection"
                    font.bold: true
                }
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    columnSpacing: 10
                    Label { text: "Device:" }
                    ComboBox {
                        id: deviceSelector
                        Layout.fillWidth: true
                        model: ["BabyMonitor1", "rpicm5"]
                        // Start with no item selected
                        currentIndex: -1
                        displayText: currentIndex > -1 ? currentText : "Please select a device..."

                        onCurrentTextChanged: {
                            ApiClient.setUrlandCert(currentText)
                            cameraController.refreshCameras()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#cccccc"
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }

                ColumnLayout {
                    id: configurationGroup
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5
                    enabled: deviceSelector.currentIndex > -1

                    // --- Top Half: Camera Selection ---
                    Label {
                        text: "Camera Configuration"
                        font.bold: true
                    }

                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        columnSpacing: 10
                        rowSpacing: 5
                        enabled: !StreamController.streaming

                        Label { text: "CameraID:" }
                        ComboBox {
                            id: cameraComboBox
                            Layout.fillWidth: true
                            model: cameraController.cameras
                            textRole: "id"
                            valueRole: "id"
                            currentIndex: -1
                            displayText: currentIndex > -1 ? currentText : "Select a camera..."
                            onCurrentIndexChanged: {
                                if(currentIndex > -1){
                                    cameraController.refreshCameras()
                                    cameraController.setActiveCamera(cameraController.cameras[currentIndex])
                                    console.log("Updated activeCamera to:", cameraController.activeCamera.id)
                                }
                            }
                        }

                        Label { text: "Current Camera:" }
                        Label {
                            text: cameraController.activeCamera !== null ? cameraController.activeCamera.id : "None selected"
                            font.italic: cameraController.activeCamera == null
                        }

                        Label { text: "Brightness:" }
                        CustomSlider {
                            id: brightnessSlider
                            from: cameraController.activeCamera.controls.brightness.min
                            to: cameraController.activeCamera.controls.brightness.max
                            value: cameraController.activeCamera.controls.brightness.value
                            onValueChanged: {
                                if (cameraController.activeCamera !== null) {
                                    console.log("Updated brightness to:", value)
                                    //cameraController.updateCameraControls(cameraController.activeCamera.id, controls);
                                }
                            }
                        }

                        Label { text: "White Balance Manual:" }
                        Switch {
                            id: manualSwitch
                            checked:  cameraController.activeCamera !== null ? !cameraController.activeCamera.controls.white_balance_automatic.value : false

                            onCheckedChanged: {
                                if (cameraController.activeCamera !== null) {
                                    console.log("Updated White Balance Enable: to:", checked)
                                }
                            }
                        }

                        Label {
                            text: "White Balance:"
                            opacity: whitebalanceSlider.enabled ? 1.0 : 0.5
                        }
                        CustomSlider {
                            id: whitebalanceSlider
                            from: cameraController.activeCamera.controls.white_balance_temperature.min
                            to: cameraController.activeCamera.controls.white_balance_temperature.max
                            value: cameraController.activeCamera.controls.white_balance_temperature.value
                            enabled: manualSwitch.checked

                            onValueChanged: {
                                if (cameraController.activeCamera !== null) {
                                    console.log("Updated White Balance Enable to:", value)
                                }
                            }
                        }

                        Button {
                            text: "Reset Controls"
                            enabled: cameraController.activeCamera !== null
                            onClicked: {
                                if (cameraController.activeCamera !== null) {
                                    cameraController.resetCameraControls(cameraController.activeCamera.id);
                                }
                            }
                        }
                    }

                    // Spacer to push the rest of the controls to the bottom half
                    Item {
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#cccccc"
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                    }

                    // --- Bottom Half: Stream Settings and Actions ---
                    Label {
                        text: "Stream Configuration"
                        font.bold: true
                    }

                    GridLayout {
                        columns: 2
                        Layout.fillWidth: true
                        columnSpacing: 10
                        rowSpacing: 5

                        Label { text: "Camera:" }
                        Label {
                            text: cameraComboBox.currentIndex > -1 ? cameraComboBox.currentText : "No camera selected"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            font.italic: cameraComboBox.currentIndex === -1
                        }

                        // Format, Resolution, FPS selectors
                        Label { text: "Format:" }
                        ComboBox {
                            id: formatComboBox
                            Layout.fillWidth: true

                            //enabled: cameraComboBox.currentIndex > -1 && !StreamController.streaming
                            //model: cameraComboBox.currentIndex > -1 ? CameraController.getFormatsForCamera(cameraComboBox.currentValue) : []
                            //onCurrentTextChanged: {
                                // resolutionComboBox.model = [];
                                // fpsComboBox.model = [];
                                // if (currentText && cameraComboBox.currentIndex > -1) {
                                //     resolutionComboBox.model = CameraController.getResolutionsForFormat(cameraComboBox.currentValue, currentText);
                                // }
                            //}
                        }
                        Label { text: "Resolution:" }
                        ComboBox {
                            id: resolutionComboBox
                            Layout.fillWidth: true
                            // enabled: formatComboBox.currentIndex > -1 && !StreamController.streaming
                            // onCurrentTextChanged: {
                            //     fpsComboBox.model = [];
                            //     if (currentText && formatComboBox.currentText && cameraComboBox.currentIndex > -1) {
                            //         fpsComboBox.model = CameraController.getFpsForResolution(cameraComboBox.currentValue, formatComboBox.currentText, currentText);
                            //     }
                            // }
                        }
                        Label { text: "FPS:" }
                        ComboBox {
                            id: fpsComboBox
                            Layout.fillWidth: true
                            //enabled: resolutionComboBox.currentIndex > -1 && !StreamController.streaming
                        }
                    }

                    // --- Action Buttons ---
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        Layout.bottomMargin: 5

                        Button {
                            text: "Start Stream"
                            // enabled: isReadyToStream && !StreamController.streaming
                            // onClicked: {
                            //     const resolutionParts = resolutionComboBox.currentText.split('x');
                            //     StreamController.startStream(
                            //         cameraComboBox.currentValue,
                            //         cameraController.activeCamera.id,
                            //         parseInt(fpsComboBox.currentText),
                            //         parseInt(resolutionParts[0]),
                            //         parseInt(resolutionParts[1])
                            //     );
                            // }
                        }

                        Button {
                            text: "Stop Stream"
                            // enabled: StreamController.streaming
                            // onClicked: StreamController.stopStream()
                        }
                    }
                }
            }
        }

        // --- Right Panel: Video Display ---
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            StackLayout {
                anchors.fill: parent
                //currentIndex: StreamController.streaming && StreamController.streamUrl.toString() !== "" ? 1 : 0
                Rectangle {
                    color: "black"
                    Label {
                        anchors.centerIn: parent
                        color: "white"
                        //text: StreamController.streaming ? "Connecting..." : "Stream not active."
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                Video {
                    id: videoPlayer
                    //source: StreamController.streamUrl
                    autoPlay: true
                    fillMode: VideoOutput.PreserveAspectFit
                }
            }
        }
    }

    // --- Global Error Handling ---
    Connections {
        target: cameraController
        function onError(message) {
            errorDialog.text = "Camera Error: " + message
            errorDialog.open()
        }
    }
    // Connections {
    //     target: StreamController
    //     function onError(message) {
    //         errorDialog.text = "Stream Error: " + message
    //         errorDialog.open()
    //     }
    // }
    Dialog {
        id: errorDialog
        title: "Error"
        standardButtons: Dialog.Ok
        modal: true
        Text { text: parent.text }
    }
}
