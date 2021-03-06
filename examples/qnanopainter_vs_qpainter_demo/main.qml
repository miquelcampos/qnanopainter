import QtQuick 2.4
import QtQuick.Window 2.2
import DemoQPItem 1.0
import DemoQNanoItem 1.0
import "qml"

Window {
    id: mainWindow

    property real animationTime: 0
    // Cutting corners a bit and not using enum
    // 1=ruler, 2=circles, 4=lines, 8=bars, 16=icons
    property int enabledTests: 31
    // Multiplier to make tests tougher
    property int testCount: 1
    property bool fullScreen: true
    property bool useNVGQ: true
    // Resolution-independent dp
    property real dp: Screen.pixelDensity * 25.4/160
    // This will be 1 on most platforms, 2 on iOS double retina, 3 on iPhone6 plus
    property int dPRatio: Screen.devicePixelRatio

    width: 375
    height: 667
    visible: true
    minimumWidth: 400*dp

    color: "#404040"

    NumberAnimation on animationTime {
        id: animationTimeAnimation
        from: 0
        to: 360
        duration: 1000*360
        loops: Animation.Infinite
    }

    Item {
        id: graphContainer
        width: mainWindow.fullScreen ? parent.width : 256
        height: mainWindow.fullScreen ? parent.height - fpsItem.height : 256
        y: mainWindow.fullScreen ? fpsItem.height : (parent.height - height)/2
        x: mainWindow.fullScreen ? 0 : (parent.width - width)/2

        Item {
            id: sizeAnimatedContainer
            width: parent.width
            height: parent.height

            DemoQNanoItem {
                id: qnItem
                width: parent.width
                height: visible ? parent.height : 0
                enabledTests: mainWindow.enabledTests
                testCount: mainWindow.testCount
                animationTime: visible ? mainWindow.animationTime : 0
                visible: useNVGQ
                //fillColor: Qt.rgba(0.2, 0.4, 0.5, 1.0)
            }

            DemoQPItem {
                id: qpItem
                // QQuickPaintedItem doesn't currently support iOS retina resolutions
                // So scaling manually is required
                width: parent.width * dPRatio
                height: visible ? parent.height * dPRatio : 0
                scale: 1 / dPRatio
                transformOrigin: Item.TopLeft
                // Instead above you can switch to this, then pixel amount of item
                // will be 1/4 on iOS & OSX
                //anchors.fill: parent
                enabledTests: mainWindow.enabledTests
                testCount: mainWindow.testCount
                animationTime: visible ? mainWindow.animationTime : 0
                visible: !useNVGQ
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    animationTimeAnimation.paused = !animationTimeAnimation.paused
                }
            }
        }
    }

    SettingsView {
        id: settigsView
    }

    FpsItem {
        id: fpsItem
    }

    Button {
        anchors.verticalCenter: fpsItem.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 60 * dp
        text: useNVGQ ? "QNanoPainter" : "QPainter"
        onClicked: {
            useNVGQ = !useNVGQ;
        }
    }

    SequentialAnimation {
        id: sizeAnimation
        loops: Animation.Infinite
        NumberAnimation  {
            target: sizeAnimatedContainer
            property: "height"
            from: graphContainer.height
            to: graphContainer.height * 0.5
            duration: 1000
            easing.type: Easing.InOutQuad
        }
        NumberAnimation  {
            target: sizeAnimatedContainer
            property: "height"
            from: graphContainer.height * 0.5
            to: graphContainer.height
            duration: 1000
            easing.type: Easing.InOutQuad
        }
    }
}
