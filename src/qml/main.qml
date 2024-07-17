import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Cutie
import Cutie.Wlc

CutieWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Launcher")

    function addApp(data) {
        launcherApps.append(data)
    }

    CutieWlc {
        id: compositor
    }

    GridView {
        id: launchAppGrid
        anchors.fill: parent
        model: launcherApps
        cellWidth: width / Math.floor(width / 85)
        cellHeight: cellWidth

        property real tempContentY: 0
        property bool refreshing: false


        onAtYBeginningChanged: {
            if(atYBeginning){
                tempContentY = contentY
            }
        }

        onContentYChanged: {
            if(atYBeginning){
                if(Math.abs(tempContentY - contentY) > 30){
                    if(refreshing){
                        return;
                    } else {
                        refreshing = true;
                    }
                }
            }
        }

        onMovementEnded: {
            if (refreshing) {
                launcherApps.clear();
                launcher.loadAppList();
                refreshing = false;
            }
        }

        delegate: Item {
            width: launchAppGrid.cellWidth
            height: launchAppGrid.cellHeight

            property bool longPress: false
            property alias menu: menu

            CutieButton {
                id: appIconButton
                anchors.fill: parent
                icon.name: model["Desktop Entry/Icon"]
                icon.source: "file://" + model["Desktop Entry/Icon"]
                icon.height: parent.height / 2
                icon.width: parent.height / 2
                background: null

                onPressed: {
                    longPress = false
                    longPressTimer.start()
                }

                onReleased: {
                    longPressTimer.stop()
                    if (!longPress) {
                        compositor.execApp(model["Desktop Entry/Exec"])
                    }
                }
            }

            CutieMenu {
                id: menu
                Repeater {
                    model: 5
                    CutieMenuItem {
                        text: qsTr("Menu Item %1").arg(index)
                        onTriggered: {
                            // Handle menu item click
                        }
                    }
                }
            }

            CutieLabel {
                anchors.bottom: appIconButton.bottom
                anchors.horizontalCenter: appIconButton.horizontalCenter
                text: model["Desktop Entry/Name"]
                font.pixelSize: 12
                clip: true
                width: 2 * appIconButton.width / 3
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            Timer {
                id: longPressTimer
                interval: 1000
                repeat: false
                onTriggered: {
                    longPress = true
                    menu.open()
                }
            }
        }
    }

    ListModel { id: launcherApps }
}