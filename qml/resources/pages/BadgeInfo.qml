import Qt 4.7
import "../components"

Rectangle {
    signal venue(string venueID)

    id: badgeInfo
    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain
    state: "hidden"

    property string name: ""
    property string image: ""
    property string info: ""
    property string venueName: ""
    property string venueID: ""
    property string time: ""

    Flickable{
        id: flickableArea
        width: parent.width
        height: parent.height
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            x: 10
            y: 20
            width: parent.width - 20
            spacing: 20

            onHeightChanged: {
                flickableArea.contentHeight = y + height + spacing;
            }

            Image {
                width: 300
                height: 300
                anchors.horizontalCenter: parent.horizontalCenter
                source: image

                Image {
                    anchors.centerIn: parent
                    source: "../pics/"+theme.name+"/loader.png"
                    visible: (parent.status != Image.Ready)
                }
            }

            Text {
                x: 10
                font.pixelSize: theme.font.sizeSettigs
                color: theme.colors.textColorOptions
                text: name
            }

            Text {
                x: 10
                width: parent.width - 20
                text: badgeInfo.info
                color: theme.colors.textColorOptions
                font.pixelSize: theme.font.sizeDefault
                wrapMode: Text.WordWrap
            }


            Text {
                x: 10
                text: '@ ' + venueName
                width: parent.width - 20
                font.pixelSize: theme.font.sizeDefault
                color: theme.colors.textColorOptions
                wrapMode: Text.WordWrap
                visible: venueName.length>0
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        badgeInfo.venue(venueID);
                    }
                }
            }
            Text {
                x: 10
                width: parent.width - 20
                text: time
                color: theme.colors.textColorTimestamp
                font.pixelSize: theme.font.sizeSigns
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: badgeInfo
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: badgeInfo
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: badgeInfo
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: badgeInfo
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: badgeInfo
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: badgeInfo
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: badgeInfo
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}