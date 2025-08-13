import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtWebEngine
import BabyMonitor 1.0

GridLayout {
    columns: 2
    columnSpacing: 10
    rowSpacing: 5
    enabled: !StreamController.streaming
    
    Label {
        text: "CameraID:"
    }
    ComboBox {
        id: cameraComboBox
        Layout.fillWidth: true
        model: cameraController.cameras
        textRole: "id"
        valueRole: "id"
        currentIndex: -1
        displayText: currentIndex > -1 ? currentText : "Select a camera..."
        onCurrentIndexChanged: {
            if (currentIndex > -1) {
                cameraController.setActiveCamera(
                            cameraController.cameras[currentIndex])
                console.log("Updated activeCamera to:",
                            cameraController.activeCamera.id)
                resolutionComboBox.model = cameraController.getResolutions(
                            cameraController.activeCamera.id)
                fpsComboBox.model = cameraController.getFpsForResolution(
                            cameraController.activeCamera.id,
                            resolutionComboBox.currentText)
            }
        }
    }
    
    Label {
        text: "Brightness:"
    }
    CustomSlider {
        id: brightnessSlider
        from: cameraController.activeCamera.controls.brightness.min
        to: cameraController.activeCamera.controls.brightness.max
        value: cameraController.activeCamera.controls.brightness.value
        
        onPressedChanged: {
            if (!pressed
                    && cameraController.activeCamera !== null) {
                console.log("Updated brightness to:", value)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "brightness", value)
            }
        }
    }
    
    Label {
        text: "Backlight Compensation:"
    }
    CustomSlider {
        id: backlightSlider
        from: cameraController.activeCamera.controls.backlight_compensation.min
        to: cameraController.activeCamera.controls.backlight_compensation.max
        value: cameraController.activeCamera.controls.backlight_compensation.value
        
        onPressedChanged: {
            if (!pressed
                    && cameraController.activeCamera !== null) {
                console.log("Updated Backlight Compensation to:",
                            value)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "backlight_compensation", value)
            }
        }
    }
    
    Label {
        text: "Contrast:"
    }
    CustomSlider {
        id: contrastSlider
        from: cameraController.activeCamera.controls.contrast.min
        to: cameraController.activeCamera.controls.contrast.max
        value: cameraController.activeCamera.controls.contrast.value
        
        onPressedChanged: {
            if (!pressed
                    && cameraController.activeCamera !== null) {
                console.log("Updated Contrast to:", value)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "contrast", value)
            }
        }
    }
    
    Label {
        text: "Gain:"
    }
    CustomSlider {
        id: gainSlider
        from: cameraController.activeCamera.controls.gain.min
        to: cameraController.activeCamera.controls.gain.max
        value: cameraController.activeCamera.controls.gain.value
        
        onPressedChanged: {
            if (!pressed
                    && cameraController.activeCamera !== null) {
                console.log("Updated brightness to:", value)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "gain", value)
            }
        }
    }
    
    Label {
        text: "Saturation:"
    }
    CustomSlider {
        id: saturationSlider
        from: cameraController.activeCamera.controls.saturation.min
        to: cameraController.activeCamera.controls.saturation.max
        value: cameraController.activeCamera.controls.saturation.value
        
        onPressedChanged: {
            if (!pressed
                    && cameraController.activeCamera !== null) {
                console.log("Updated Saturation to:", value)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "saturation", value)
            }
        }
    }
    
    Label {
        text: "Sharpness:"
    }
    CustomSlider {
        id: sharpnessSlider
        from: cameraController.activeCamera.controls.sharpness.min
        to: cameraController.activeCamera.controls.sharpness.max
        value: cameraController.activeCamera.controls.sharpness.value
        
        onPressedChanged: {
            if (!pressed
                    && cameraController.activeCamera !== null) {
                console.log("Updated Sharpness to:", value)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "sharpness", value)
            }
        }
    }
    
    Label {
        text: "Manual Exposure:"
    }
    Switch {
        id: exposureSwitch
        checked: (cameraController.activeCamera !== null)
                 && (cameraController.activeCamera.controls.auto_exposure.value
                     === 1) ? true : false
        onCheckedChanged: {
            if (cameraController.activeCamera !== null) {
                console.log("Updated Manual Exposure to:",
                            checked)
                var value = checked ? 1 : 3
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "auto_exposure", value)
            }
        }
    }
    
    Label {
        text: "Exposure:"
    }
    CustomSlider {
        id: exposureSlider
        from: cameraController.activeCamera.controls.exposure_time_absolute.min
        to: cameraController.activeCamera.controls.exposure_time_absolute.max
        value: cameraController.activeCamera.controls.exposure_time_absolute.value
        enabled: exposureSwitch.checked
        
        onPressedChanged: {
            if (!pressed
                    && cameraController.activeCamera !== null) {
                console.log("Updated Sharpness to:", value)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "exposure_time_absolute", value)
            }
        }
    }
    
    Label {
        text: "Manual White Balance:"
    }
    Switch {
        id: manualSwitch
        checked: cameraController.activeCamera !== null ? !cameraController.activeCamera.controls.white_balance_automatic.value : false
        onCheckedChanged: {
            if (cameraController.activeCamera !== null) {
                console.log("Updated White Balance Enable to:",
                            checked)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "white_balance_automatic",
                            !checked)
            }
        }
    }
    
    Label {
        text: "White Balance:"
    }
    CustomSlider {
        id: whitebalanceSlider
        from: cameraController.activeCamera.controls.white_balance_temperature.min
        to: cameraController.activeCamera.controls.white_balance_temperature.max
        value: cameraController.activeCamera.controls.white_balance_temperature.value
        enabled: manualSwitch.checked
        
        onPressedChanged: {
            if (!pressed
                    && cameraController.activeCamera !== null) {
                console.log("Updated White Balance to:",
                            value)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "white_balance_temperature",
                            value)
            }
        }
    }
    
    Label {
        text: "Power Line Frequency"
    }
    ComboBox {
        id: powerlineComboBox
        Layout.fillWidth: true
        model: [{
                "value": 0,
                "text": qsTr("Disabled")
            }, {
                "value": 1,
                "text": qsTr("50 Hz")
            }, {
                "value": 2,
                "text": qsTr("60 Hz")
            }]
        textRole: "text"
        
        currentIndex: {
            if (cameraController.activeCamera)
                return cameraController.activeCamera.controls.power_line_frequency.value
            else
                return -1
        }
        
        onCurrentIndexChanged: {
            if (cameraController.activeCamera !== null
                    && currentIndex > -1) {
                console.log("Updated power line frequency to:",
                            currentIndex)
                cameraController.updateCameraControl(
                            cameraController.activeCamera.id,
                            "power_line_frequency",
                            currentIndex)
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
                cameraController.resetCameraControls(
                            cameraController.activeCamera.id)
            }
        }
    }
}
