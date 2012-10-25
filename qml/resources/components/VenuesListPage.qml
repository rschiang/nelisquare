import Qt 4.7

Rectangle {
    id: venuesList
    signal clicked(string venueid)
    signal search(string query)

    property alias placesModel: placesModel

    width: parent.width
    height: parent.height
    color: theme.backgroundMain
    state: "hidden"

    function hideKeyboard() {
        searchText.closeSoftwareInputPanel();
        window.focus = true;
    }

    ListModel {
        id: placesModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        y: 110
        width: parent.width
        height: parent.height - y
        model: placesModel
        delegate: venuesListDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400
        spacing: 5
    }

    GreenLine {
        y: 80
        height: 30
        text: "PLACES NEAR YOU"
    }

    Rectangle {
        width: parent.width
        height: 80
        color: theme.backgroundBlueDark

        Rectangle {
            id: textContainer
            height: 40
            width: parent.width - 150
            x: 10
            y: 20
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ccc" }
                GradientStop { position: 0.1; color: "#fafafa" }
                GradientStop { position: 1.0; color: "#fff" }
            }
            border.width: 1
            border.color: "#aaa"
            smooth: true

            TextInput {
                id: searchText
                text: theme.textSearchVenue
                width: parent.width - 10
                height: parent.height - 10
                x: 5
                y: 5
                color: "#111"
                font.pixelSize: 24

                onAccepted: {
                    var query = searchText.text;
                    if(query==theme.textSearchVenue) {
                        query = "";
                    }
                    venuesList.search(query);
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        searchText.focus = true;
                        if(searchText.text==theme.textSearchVenue) {
                            searchText.text = "";
                        }
                        if (searchText.text != "") {
                            searchText.cursorPosition = searchText.positionAt(mouseX,mouseY);
                        }
                    }
                }
            }
        }

        BlueButton {
            x: parent.width - width - 10
            y: 20
            height: 40
            label: "SEARCH"
            width: 120

            onClicked: {
                // Search
                var query = searchText.text;
                if(query==theme.textSearchVenue) {
                    query = "";
                }
                hideKeyboard();
                venuesList.search(query);
            }
        }


    }

    Component {
        id: venuesListDelegate

        Item {
            id: placesItem
            width: parent.width
            height: titleContainer.height + 2

            Rectangle {
                id: titleContainer
                color: mouseArea.pressed ? "#ddd" : theme.backgroundMain
                y: 1
                width: parent.width
                height: statusTextArea.height + 8 < 64 ? 64 : statusTextArea.height + 8

                Image {
                    x: 8
                    y: 4
                    id: buildingImage
                    source: cache.get(icon)
                    width: 32
                    height: 32
                }

                Column {
                    id: statusTextArea
                    spacing: 4
                    x: buildingImage.width + 16
                    y: 4
                    width: parent.width - x - 16

                    Row {
                        spacing: 10
                        width: parent.width

                        Text {
                            id: messageText
                            color: "#333"
                            font.pixelSize: 24
                            //width: parent.width / 2
                            text: name
                            font.bold: true
                            wrapMode: Text.Wrap
                        }
                    }
                    Text {
                        id: todoText
                        color: "#666"
                        font.pixelSize: 16
                        width: parent.width
                        text: todoComment
                        visible: todoComment.length>0
                        wrapMode: Text.Wrap
                    }

                    Row {
                        width: parent.width
                        spacing: 10
                        Text {
                            id: distanceText
                            color: "#666"
                            font.pixelSize: 16
                            text: distance + " meters  "
                            wrapMode: Text.Wrap
                        }
                        Image {
                            id: hereNowImage
                            source: "../pics/peoples.png"
                            fillMode: Image.PreserveAspectFit
                            height: distanceText.height
                            visible: hereNow > 0
                        }

                        Text {
                            text: hereNow
                            font.pixelSize: 16
                            visible: hereNow > 0
                        }
                    }
                }
            }

            /* //separator
            Rectangle {
                width:  parent.width
                x: 4
                y: placesItem.height - 1
                height: 1
                color: "#ccc"
            }*/

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    venuesList.clicked( model.id );
                }
            }

        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: venuesList
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: venuesList
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: venuesList
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: venuesList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: venuesList
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: venuesList
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: venuesList
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}