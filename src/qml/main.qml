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

    function addApp(data) {

    }
    function loadAllApps() {

        console.log("App Details loading stage 2 ");

        let allApps = CutieDesktopFilePhraser.fetchAllEntries(); // Get all entries
        launcherApps.clear(); // Clear existing entries if needed
        console.log("App Details loading stage 3");
        // Iterate through each app entry and append to launcherApps
        for (let i = 0; i < allApps.length; i++) {
            let appDetails = allApps[i];
            // Log the contents of appDetails
            console.log("App Details:", appDetails);

            let data = {
                "Desktop Entry/Name": appDetails["Name"], // Adjust according to the actual key
                "Desktop Entry/Icon": appDetails["Icon"],
                "Desktop Entry/Exec": appDetails["Exec"]
            };
            launcherApps.append(data); // Append new app data to the model
        }
    }

    // Call loadAllApps when the window is shown or at some other appropriate time
    Component.onCompleted: {
        console.log("App Details loading stage 1");
        loadAllApps(); // Adjust the path accordingly
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
