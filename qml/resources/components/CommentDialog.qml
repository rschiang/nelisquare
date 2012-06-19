import Qt 4.7

Rectangle {
    id: comment
    width: parent.width
    height: items.height + 20
    color: theme.toolbarLightColor
    state: "hidden"
    property string comment: "Write here"
    property string checkinID: ""
    signal cancel()
    signal shout(string comment)

    function reset() {
        commentText.text = "Write here";
    }

    function hideKeyboard() {
        commentText.closeSoftwareInputPanel();
        window.focus = true;
    }


    Column {
        id: items
        x: 10
        y: 10
        width: parent.width - 20
        spacing: 10

        Text {
            id: venueName
            text: "What is on your mind?"
            width: parent.width
            font.pixelSize: 24
            color: "#fff"
        }

        Rectangle {
            id: commentBox
            height: 100
            width: parent.width
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ccc" }
                GradientStop { position: 0.1; color: "#fafafa" }
                GradientStop { position: 1.0; color: "#fff" }
            }
            radius: 5
            border.width: 1
            border.color: "#aaa"
            smooth: true

            TextEdit {
                id: commentText
                wrapMode: TextEdit.Wrap
                text: "Write here"
                textFormat: TextEdit.PlainText
                width: parent.width - 10
                height: parent.height - 10
                x: 5
                y: 5
                color: "#111"
                font.pixelSize: 24

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        commentText.focus = true;
                        if(commentText.text=="Write here") {
                            commentText.text = "";
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: commentButton.height

            GreenButton {
                id: commentButton
                label: "Comment!"
                width: parent.width - 130
                onClicked: {
                    hideKeyboard();
                    comment.shout( commentText.text )
                }
            }

            GreenButton {
                label: "Cancel"
                x: parent.width - 120
                width: 120
                onClicked: {
                    hideKeyboard();
                    comment.state = "hidden";
                }
            }
        }
    }

    Image {
        id: shadow
        source: "../pics/top-shadow.png"
        width: parent.width
        y: parent.height - 1
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: comment
                y: -200-comment.height
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: comment
                y: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: comment
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: comment
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: comment
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: comment
                    properties: "y"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}
