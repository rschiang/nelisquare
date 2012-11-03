import Qt 4.7
import "../components"

Rectangle {
    signal badge(variant params)

    property alias badgeModel: badgeModel

    id: badgesPage
    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain
    state: "hidden"

    ListModel {
        id: badgeModel
    }

    GridView {
        id: badgeGrid
        anchors.fill: parent
        clip: true

        cellWidth: parent.width/3
        cellHeight: cellWidth

        model: badgeModel
        delegate: badgeDelegate
        header: Item {
                width: parent.width
                height: 20
            }
    }

    Component {
        id: badgeDelegate

        Item {
            width: badgeGrid.cellWidth

            Image {
                id: badgeImage
                width: 114
                height: 114
                source: cache.get(model.image)
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    anchors.fill: badgeImage
                    onClicked: {
                        badgesPage.badge({
                                    "name":model.name,
                                    "image":model.imageLarge,
                                    "info":model.info,
                                    "venueName":model.venueName,
                                    "venueID":model.venueID,
                                    "time":model.time});
                    }
                }
                Image {
                    anchors.centerIn: badgeImage
                    source: "../pics/"+theme.name+"/loader.png"
                    visible: (badgeImage.status != Image.Ready)
                }
            }
            Text {
                text: model.name;
                y: badgeImage.y + badgeImage.height
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: theme.font.sizeSigns
                color: theme.colors.textColorOptions
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: badgesPage
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: badgesPage
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: badgesPage
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: badgesPage
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: badgesPage
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: badgesPage
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: badgesPage
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}