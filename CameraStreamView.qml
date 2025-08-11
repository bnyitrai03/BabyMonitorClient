import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtWebEngine
import BabyMonitor 1.0

Rectangle {
    id: root
    color: "#f0f0f0"

    property bool readyToStream: cameraComboBox.currentIndex > -1 &&
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
                        model: ["ncwl-a01-e03-1", "rpicm5"]
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
                                    cameraController.setActiveCamera(cameraController.cameras[currentIndex])
                                    console.log("Updated activeCamera to:", cameraController.activeCamera.id)
                                    resolutionComboBox.model = cameraController.getResolutions(cameraController.activeCamera.id)
                                    fpsComboBox.model = cameraController.getFpsForResolution(cameraController.activeCamera.id, resolutionComboBox.currentText)
                                }
                            }
                        }

                        Label { text: "Brightness:" }
                        CustomSlider {
                            id: brightnessSlider
                            from: cameraController.activeCamera.controls.brightness.min
                            to: cameraController.activeCamera.controls.brightness.max
                            value: cameraController.activeCamera.controls.brightness.value

                            onPressedChanged: {
                                if (!pressed && cameraController.activeCamera !== null) {
                                    console.log("Updated brightness to:", value)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "brightness",
                                        value
                                    )
                                }
                            }
                        }

                        Label { text: "Backlight Compensation:" }
                        CustomSlider {
                            id: backlightSlider
                            from: cameraController.activeCamera.controls.backlight_compensation.min
                            to: cameraController.activeCamera.controls.backlight_compensation.max
                            value: cameraController.activeCamera.controls.backlight_compensation.value

                            onPressedChanged: {
                                if (!pressed && cameraController.activeCamera !== null) {
                                    console.log("Updated Backlight Compensation to:", value)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "backlight_compensation",
                                        value
                                    )
                                }
                            }
                        }

                        Label { text: "Contrast:" }
                        CustomSlider {
                            id: contrastSlider
                            from: cameraController.activeCamera.controls.contrast.min
                            to: cameraController.activeCamera.controls.contrast.max
                            value: cameraController.activeCamera.controls.contrast.value

                            onPressedChanged: {
                                if (!pressed && cameraController.activeCamera !== null) {
                                    console.log("Updated Contrast to:", value)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "contrast",
                                        value
                                    )
                                }
                            }
                        }

                        Label { text: "Gain:" }
                        CustomSlider {
                            id: gainSlider
                            from: cameraController.activeCamera.controls.gain.min
                            to: cameraController.activeCamera.controls.gain.max
                            value: cameraController.activeCamera.controls.gain.value

                            onPressedChanged: {
                                if (!pressed && cameraController.activeCamera !== null) {
                                    console.log("Updated brightness to:", value)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "gain",
                                        value
                                    )
                                }
                            }
                        }

                        Label { text: "Saturation:" }
                        CustomSlider {
                            id: saturationSlider
                            from: cameraController.activeCamera.controls.saturation.min
                            to: cameraController.activeCamera.controls.saturation.max
                            value: cameraController.activeCamera.controls.saturation.value

                            onPressedChanged: {
                                if (!pressed && cameraController.activeCamera !== null) {
                                    console.log("Updated Saturation to:", value)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "saturation",
                                        value
                                    )
                                }
                            }
                        }

                        Label { text: "Sharpness:" }
                        CustomSlider {
                            id: sharpnessSlider
                            from: cameraController.activeCamera.controls.sharpness.min
                            to: cameraController.activeCamera.controls.sharpness.max
                            value: cameraController.activeCamera.controls.sharpness.value

                            onPressedChanged: {
                                if (!pressed && cameraController.activeCamera !== null) {
                                    console.log("Updated Sharpness to:", value)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "sharpness",
                                        value
                                    )
                                }
                            }
                        }

                        Label { text: "Manual Exposure:" }
                        Switch {
                            id: exposureSwitch
                            checked: (cameraController.activeCamera !== null) && (cameraController.activeCamera.controls.auto_exposure.value === 1) ? true : false
                            onCheckedChanged: {
                                if (cameraController.activeCamera !== null) {
                                    console.log("Updated Manual Exposure to:", checked)
                                    var value = checked ? 1 : 3
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "auto_exposure",
                                        value
                                    )
                                }
                            }
                        }

                        Label { text: "Exposure:" }
                        CustomSlider {
                            id: exposureSlider
                            from: cameraController.activeCamera.controls.exposure_time_absolute.min
                            to: cameraController.activeCamera.controls.exposure_time_absolute.max
                            value: cameraController.activeCamera.controls.exposure_time_absolute.value
                            enabled: exposureSwitch.checked

                            onPressedChanged: {
                                if (!pressed && cameraController.activeCamera !== null) {
                                    console.log("Updated Sharpness to:", value)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "exposure_time_absolute",
                                        value
                                    )
                                }
                            }
                        }

                        Label { text: "Manual White Balance:" }
                        Switch {
                            id: manualSwitch
                            checked:  cameraController.activeCamera !== null ? !cameraController.activeCamera.controls.white_balance_automatic.value : false
                            onCheckedChanged: {
                                if (cameraController.activeCamera !== null) {
                                    console.log("Updated White Balance Enable to:", checked)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "white_balance_automatic",
                                        !checked
                                    )
                                }
                            }
                        }

                        Label { text: "White Balance:" }
                        CustomSlider {
                            id: whitebalanceSlider
                            from: cameraController.activeCamera.controls.white_balance_temperature.min
                            to: cameraController.activeCamera.controls.white_balance_temperature.max
                            value: cameraController.activeCamera.controls.white_balance_temperature.value
                            enabled: manualSwitch.checked

                            onPressedChanged: {
                                if (!pressed && cameraController.activeCamera !== null) {
                                    console.log("Updated White Balance to:", value)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "white_balance_temperature",
                                        value
                                    )
                                }
                            }
                        }

                        Label { text: "Power Line Frequency" }
                        ComboBox {
                            id: powerlineComboBox
                            Layout.fillWidth: true
                            model:
                            [
                                { value: 0, text: qsTr("Disabled") },
                                { value: 1, text: qsTr("50 Hz") },
                                { value: 2, text: qsTr("60 Hz") }
                            ]
                            textRole: "text"

                            currentIndex: {
                                if (cameraController.activeCamera)
                                    return cameraController.activeCamera.controls.power_line_frequency.value;
                                else
                                    return -1;
                            }

                            onCurrentIndexChanged: {
                                if (cameraController.activeCamera !== null && currentIndex > -1) {
                                    console.log("Updated power line frequency to:", currentIndex)
                                    cameraController.updateCameraControl(
                                        cameraController.activeCamera.id,
                                        "power_line_frequency",
                                        currentIndex
                                    )
                                }
                            }
                        }

                        Item {} // Left empty cell
                        Button {
                            Layout.alignment: Qt.AlignLeft
                            Layout.topMargin: 10
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

                        Label { text: "Camera eye:" }
                        ComboBox {
                            id: cameraeyeComboBox
                            Layout.fillWidth: true
                            enabled: !streamController.streaming
                            textRole: "text"
                            model: [
                                { value: qsTr("Left"), text: qsTr("Left") },
                                { value: qsTr("Right"), text: qsTr("Right") }
                            ]
                        }

                        Label { text: "Resolution:" }
                        ComboBox {
                            id: resolutionComboBox
                            Layout.fillWidth: true
                            enabled: !streamController.streaming
                            model:[]
                            onCurrentIndexChanged: {
                                fpsComboBox.model = []
                                if (currentIndex > -1 && cameraController.activeCamera !== null)
                                    fpsComboBox.model = cameraController.getFpsForResolution(cameraController.activeCamera.id, currentText)
                            }
                        }

                        Label { text: "FPS:" }
                        ComboBox {
                            id: fpsComboBox
                            Layout.fillWidth: true
                            enabled: !streamController.streaming
                            model:[]
                        }
                    }

                    // --- Action Buttons ---
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        Layout.bottomMargin: 5

                        Button {
                            text: "Start Stream"
                            enabled: !streamController.streaming && readyToStream
                            onClicked: {
                                const resolutionParts = resolutionComboBox.currentText.split('x');
                                streamController.startStream(
                                    cameraController.activeCamera.id,
                                    cameraController.activeCamera.path,
                                    cameraeyeComboBox.currentText,
                                    parseInt(fpsComboBox.currentText),
                                    parseInt(resolutionParts[0]),
                                    parseInt(resolutionParts[1])
                                );
                            }
                        }

                        Button {
                            text: "Stop Stream"
                            enabled: streamController.streaming
                            onClicked: streamController.stopStream()
                        }
                    }
                }
            }
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                anchors.fill: parent
                currentIndex: streamController.streaming && streamController.streamUrl.toString() !== "" ? 1 : 0

                // --- Not streaming / connecting ---
                Rectangle {
                    color: "black"
                    Label {
                        anchors.centerIn: parent
                        color: "white"
                        text: streamController.streaming ? "Connecting..." : "Stream not active."
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                WebEngineView {
                    id: streamView
                    anchors.fill: parent
                    url: streamController.streamUrl

                    settings {
                        accelerated2dCanvasEnabled: true
                        webGLEnabled: true

                        javascriptEnabled: false
                        pluginsEnabled: false
                        autoLoadImages: true
                        touchIconsEnabled: false
                        focusOnNavigationEnabled: false
                    }

                    onCertificateError: function(error) {
                                           console.log("Certificate error:", error.description)
                                           console.log("Error URL:", error.url)
                                           // Accept the certificate error for self-signed certificates
                                           error.acceptCertificate()
                                        }
                }
            }
        }
    }

    // --- Global Error Handling ---
    Connections {
        target: cameraController
        function onError(message) {
            errorDialog.title = "Camera Error"
            errorDialog.text = message
            errorDialog.open()
        }
    }
    Connections {
        target: streamController
        function onError(message) {
            errorDialog.title = "Stream Error"
            errorDialog.text = message
            errorDialog.open()
        }
    }
    Connections {
        target: ApiClient
        function onError(message) {
            errorDialog.title = "Connection Error"
            errorDialog.text = message
            errorDialog.open()
        }
    }
    MessageDialog {
        id: errorDialog
        buttons: Dialog.Ok
        text: parent.text
    }
}
