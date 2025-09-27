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

    CutieWlc { id: compositor }

    // The model is initially undefined
    property var allAppsModel: null

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

    // Load model after the window has completed loading
    Component.onCompleted: {
        console.log("Launcher - Window loaded, initializing all apps model...")
        allAppsModel = CutieDesktopFileParser.fetchAllEntriesModel()
    }

    GridView {
        id: launchAppGrid
        anchors.fill: parent
        model: allAppsModel   // bound to the model property
        cellWidth: width / Math.floor(width / 85)
        cellHeight: cellWidth

        delegate: Item {
            width: launchAppGrid.cellWidth
            height: launchAppGrid.cellHeight

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
                    compositor.execApp(model.exe)

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
