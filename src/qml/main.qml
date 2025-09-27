import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Cutie
import Cutie.Store
import Cutie.Wlc
import Cutie.Desktopfileparser


CutieWindow {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("Launcher")

    CutieWlc {
        id: compositor
    }

    // Shared model for all apps
    property DesktopEntryModel allAppsModel: CutieDesktopFilePhraser.fetchAllEntriesModel()

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"
    }

    function saveFavoriteItem(name) {
        let data = favoriteStore.data;
        data[name] = name;
        favoriteStore.data = data;
    }

    GridView {
        id: launchAppGrid
        anchors.fill: parent
        model: allAppsModel   // bind directly to QAbstractListModel
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
            if(refreshing) {
                allAppsModel = CutieDesktopFilePhraser.fetchAllEntriesModel() // reload
                refreshing = false
            }
        }

        delegate: Item {
            width: launchAppGrid.cellWidth
            height: launchAppGrid.cellHeight

            property alias menu: menu

            CutieButton {
                id: appIconButton
                width: launchAppGrid.cellWidth
                height: width
                icon.name: model.icon
                icon.source: "file://" + model.icon
                icon.height: width / 2
                icon.width: height / 2
                background: null

                onClicked:
                    compositor.execApp(model.exec)

                onPressAndHold:
                    menu.open()
            }

            CutieMenu {
                id: menu
                width: window.width / 2
                CutieMenuItem {
                    text: qsTr("Add to favorites")
                    onTriggered: saveFavoriteItem(model.name)
                }
            }

            CutieLabel {
                anchors.bottom: appIconButton.bottom
                anchors.horizontalCenter: appIconButton.horizontalCenter
                text: model.name
                font.pixelSize: 12
                clip: true
                width: 2 * appIconButton.width / 3
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
