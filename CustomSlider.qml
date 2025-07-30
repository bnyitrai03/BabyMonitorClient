import QtQuick 2.15
import QtQuick.Controls 2.15

Slider {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitHandleWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitHandleHeight + topPadding + bottomPadding)
    spacing: 3
    padding: 6
    stepSize: 1
    snapMode: Slider.SnapOnRelease

    property alias tooltip: tooltip

    handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.vertical ? control.visualPosition * (control.availableHeight - height) : (control.availableHeight - height) / 2)

        implicitWidth: 15
        implicitHeight: 15

        radius: width/2

        border.width: control.pressed ? width/2 : 1
        border.color: black
        opacity: control.enabled ? 1.0 : 0.4

        Behavior on border.width { SmoothedAnimation {} }

        ToolTip {
            id: tooltip

            x: control.vertical ? control.spacing + parent.width : (15 - width)/2
            y: control.horizontal ? -control.spacing - parent.width : (15 - height)/2

            padding: 3
            opacity: 0.8
            visible: control.pressed

            parent: control.handle

            text: control.value.toFixed((control.stepSize + '.').split('.')[1].length)
            font.pixelSize: parent.width/2

            delay: 100; timeout: 0

            background: Rectangle { radius: 3; border.width: 1; opacity: 0.2 }
        }
    }

    background: Rectangle {
        x: (control.width  - width) / 2
        y: (control.height - height) / 2

        implicitWidth: control.horizontal ? 200 : 1
        implicitHeight: control.horizontal ? 1 : 200

        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight

        radius: width
        color: Qt.darker(control.palette.button)
        opacity: control.enabled ? 1.0 : 0.4
    }
}
