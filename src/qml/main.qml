import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Cutie
import Cutie.Store
import Cutie.Wlc
import Cutie.Desktopfilephraser


CutieWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Launcher")

    CutieWlc {
        id: compositor
    }


    function addApp(data) {

    }
    function loadAllApps() {
        let allApps = CutieDesktopFilePhraser.fetchAllEntries();
        launcherApps.clear(); 

        console.log("Launcher : Loading app entries, number of entries:", allApps.length);

        for (const app of allApps) {
            launcherApps.append(app);
        }
    }

    // Call loadAllApps when the window is loaded
    Component.onCompleted: {
        loadAllApps();
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
                loadAllApps();
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
                onClicked:
                    compositor.execApp(model["Desktop Entry/Exec"])
                onPressAndHold:
                    menu.open()
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
              appName: "cutie-launcher"
              storeName: "favoriteItems"
            }

            function saveFavoriteItem(name, iconPath, execCommand) {
               let data = favoriteStore.data;
               data["favoriteApp-" + name] = { "icon": iconPath, "command": execCommand };
               favoriteStore.data = data;
            }

        }
    }

    ListModel { id: launcherApps }
}
