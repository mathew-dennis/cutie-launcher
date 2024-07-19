import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Cutie
import Cutie.Store
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
                width: launchAppGrid.cellWidth
                height: width
                icon.name: model["Desktop Entry/Icon"]
                icon.source: "file://" + model["Desktop Entry/Icon"]
                icon.height: width / 2
                icon.width: height / 2
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
                width: window.width / 2
                CutieMenuItem {
                    text: qsTr("Add to favorites")
                    onTriggered: {
                        saveFavoriteItem(model["Desktop Entry/Name"], model["Desktop Entry/Icon"], model["Desktop Entry/Exec"]);
                    }
                }

                CutieMenuItem {
                    text: qsTr("Remove from favorites")
                    onTriggered: {
                        removeFavoriteItem(model["Desktop Entry/Name"]);
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
            
            CutieStore {
              id: favoriteStore
              appName: "cutie-panel"
              storeName: "favoriteItems"
            }

            function saveFavoriteItem(name, iconPath, execCommand) {
               let data = favoriteStore.data;
               data["favoriteApp-" + name] = { "icon": iconPath, "command": execCommand };
               favoriteStore.data = data;
            }

            function removeFavoriteItem(name) {
                let data = favoriteStore.data;
                if (data.hasOwnProperty("favoriteApp-" + name)) {
                    delete data["favoriteApp-" + name];
                    favoriteStore.data = data;
                } 
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
