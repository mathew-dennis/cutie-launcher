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
            CutieButton {
                id: appIconButton
                width: launchAppGrid.cellWidth
                height: width
                icon.name: model["Desktop Entry/Icon"]
                icon.source: "file://" + model["Desktop Entry/Icon"]
                icon.height: width / 2
                icon.width: height / 2
                background: null
                onClicked:
                    compositor.execApp(model["Desktop Entry/Exec"]);
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
        }
    }

    ListModel { id: launcherApps }
}