import Qt 4.7
import "../components"

Rectangle {
    signal openLeaderboard()
    signal user(string user)
    signal venue(string venue);

    signal addFriend(string user)
    signal removeFriend(string user)
    signal approveFriend(string user)
    signal denyFriend(string user)

    signal badges(string user)
    signal checkins(string user)
    signal mayorships(string user)
    signal friends(string user)
    signal photos(string user)
    signal tips(string user)

    id: details
    width: parent.width
    height: parent.height
    color: theme.colors.backgroundMain
    state: "hidden"

    property string userID: ""
    property string userName: ""
    property string userPhoto: ""
    property string userPhotoLarge: ""

    property string userContactPhone: ""
    property string userContactEmail: ""
    property string userContactTwitter: ""
    property string userContactFacebook: ""

    property int userBadgesCount: 0
    property int userMayorshipsCount: 0
    property int userCheckinsCount: 0
    property int userFriendsCount: 0
    property int userPhotosCount: 0
    property int userTipsCount: 0

    property string userRelationship: "undefined"

    property int userLeadersboardRank: 0

    property int scoreRecent: 0
    property int scoreMax: 0

    property string lastVenue: ""
    property string lastVenueID: ""
    property string lastTime: ""

    property alias boardModel: boardModel

    Component.onCompleted: {
        checkinOwner.userPhoto.photoSize = 200;
    }

    onUserPhotoChanged: {
        checkinOwner.userPhoto.photoSize = 200;
        checkinOwner.userPhoto.photoUrl = details.userPhoto;
    }

    function switchUserPhoto() {
        if (checkinOwner.userPhoto.photoSize == checkinOwner.width) {
            checkinOwner.userPhoto.photoSize = 200;
            checkinOwner.userPhoto.photoUrl = details.userPhoto;
            checkinOwner.showText = true;
            //socialRow.visible = true;
        } else {
            checkinOwner.userPhoto.photoSize = checkinOwner.width;
            checkinOwner.userPhoto.photoUrl = details.userPhotoLarge;
            checkinOwner.showText = false;
            //socialRow.visible = false;
        }
    }

    ListModel {
        id: boardModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Flickable{

        id: flickableArea
        width: parent.width
        contentWidth: parent.width
        height: details.height - y

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            onHeightChanged: {
                flickableArea.contentHeight = height + y + spacing;
            }

            width: parent.width - 20
            y: 10
            x: 10
            spacing: 10

            EventBox {
                id: checkinOwner
                width: parent.width

                userName: details.userName
                userShout: "@ " + details.lastVenue
                createdAt: details.lastTime

                onUserClicked: {
                    switchUserPhoto();
                }
                onAreaClicked: {
                    if (lastVenueID !== "")
                        details.venue(lastVenueID);
                }

                Row {
                    id: socialRow
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.right: parent.right
                    spacing: 10

                    Image {
                        width: 48
                        height: 48
                        smooth: true
                        source: "../pics/phone.png"

                        MouseArea {
                            anchors. fill: parent
                            onClicked: {
                                waiting.show();
                                Qt.openUrlExternally("tel:" + userContactPhone);
                                waiting.hide();
                            }
                        }
                        visible: userContactPhone !== ""
                    }
                    Image {
                        width: 48
                        height: 48
                        smooth: true
                        source: "../pics/email.png"

                        MouseArea {
                            anchors. fill: parent
                            onClicked: {
                                waiting.show();
                                Qt.openUrlExternally("mailto:" + userContactEmail + "?subject=Ping from Foursquare");
                                waiting.hide();
                            }
                        }
                        visible: userContactEmail !== ""
                    }
                    Image {
                        width: 48
                        height: 48
                        smooth: true
                        source: "../pics/twitter.png"

                        MouseArea {
                            anchors. fill: parent
                            onClicked: {
                                waiting.show();
                                Qt.openUrlExternally("https://twitter.com/" + userContactTwitter);
                                waiting.hide();
                            }
                        }
                        visible: userContactTwitter !== ""
                    }
                    Image {
                        width: 48
                        height: 48
                        smooth: true
                        source: "../pics/facebook.png"

                        MouseArea {
                            anchors. fill: parent
                            onClicked: {
                                waiting.show();
                                Qt.openUrlExternally("https://facebook.com/" + userContactFacebook);
                                waiting.hide();
                            }
                        }
                        visible: userContactFacebook !== ""
                    }
                }
            }

            ButtonGreen {
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Add Friend"
                width: parent.width - 130
                onClicked: {
                    details.addFriend(userID);
                }
                visible: userRelationship == ""
            }

            Row {
                width: parent.width
                spacing: 50
                ButtonBlue {
                    label: "Approve Friend"
                    width: parent.width * 0.6
                    onClicked: {
                        details.approveFriend(userID);
                    }
                }
                ButtonGray {
                    label: "Deny"
                    width: parent.width * 0.3
                    onClicked: {
                        details.denyFriend(userID);
                    }
                }
                visible: userRelationship == "pendingMe"
            }

            ButtonGray {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 130
                label: "Remove Friend"
                onClicked: {
                    details.removeFriend(userID);
                }
                visible: (userRelationship == "friend" || userRelationship == "pendingThem")
            }

            //scores title
            Item {
                width: parent.width
                height: children[0].height
                Text {
                    id: lblScoresText
                    text: "<b>SCORES</b> (LAST 7 DAYS)"
                    font.pixelSize: theme.font.sizeHelp
                    color: theme.colors.textColorOptions
                }
                Text {
                    text: "BEST SCORE"
                    anchors.right: parent.right
                    font.pixelSize: theme.font.sizeHelp
                    font.bold: true
                    color: theme.colors.textColorOptions
                }
            }
            //scores value
            Item {
                width: parent.width
                height: children[0].height

                ProgressBar {
                    width: parent.width * 0.85
                    percent: scoreRecent
                    percentMax: scoreMax
                    showPercent: true
                }
                Text {
                    text: scoreMax
                    anchors.right: parent.right
                    color: theme.colors.textColorOptions
                    font.bold: true
                    font.pixelSize: theme.font.sizeHelp
                }
            }

            Item {
                width: parent.width
                height: 230

                Rectangle {
                    id: badgesCount
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.right: checkinsCount.left
                    anchors.rightMargin: 10

                    width: (parent.width - 40) / 3
                    height: 100
                    color: theme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    Image {
                        y: 10
                        width: 64
                        height: 64
                        source: cache.get("https://playfoursquare.s3.amazonaws.com/badge/114/newbie.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: theme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userBadgesCount + " " + "Badges"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.badges(userID);
                        }
                    }
                }

                Rectangle {
                    id: checkinsCount
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: (parent.width - 40) / 3
                    height: 100
                    color: theme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    Image {
                        y: 10
                        width: 64
                        height: 64
                        source: cache.get("https://playfoursquare.s3.amazonaws.com/badge/114/bender.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: theme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userCheckinsCount + " " + "Checkins"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (userRelationship == "self") {
                                details.checkins(userID);
                            }
                        }
                    }
                }

                Rectangle {
                    id: mayorCount
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: checkinsCount.right
                    anchors.leftMargin: 10
                    width: (parent.width - 40) / 3
                    height: 100
                    color: theme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    Image {
                        y: 10
                        width: 64
                        height: 64
                        source: cache.get("https://playfoursquare.s3.amazonaws.com/badge/114/supermayor.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: theme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userMayorshipsCount + " " + "Mayorships"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.mayorships(userID);
                        }
                    }
                }

                Rectangle {
                    id: friendsCount
                    anchors.top: checkinsCount.bottom
                    anchors.topMargin: 10
                    anchors.right: checkinsCount.left
                    anchors.rightMargin: 10
                    width: (parent.width - 40) / 3
                    height: 100
                    color: theme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    Image {
                        y: 10
                        width: 64
                        height: 64
                        source: cache.get("https://playfoursquare.s3.amazonaws.com/badge/114/entourage.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: theme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userFriendsCount + " " + "Friends"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.friends(userID);
                        }
                    }
                }

                Rectangle {
                    id: photosCount
                    anchors.top: checkinsCount.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: checkinsCount.horizontalCenter
                    width: (parent.width - 40) / 3
                    height: 100
                    color: theme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    Image {
                        y: 10
                        width: 64
                        height: 64
                        source: cache.get("https://playfoursquare.s3.amazonaws.com/badge/114/photogenic.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: theme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userPhotosCount + " " + "Photos"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.photos(userID);
                        }
                    }
                }

                Rectangle {
                    id: tipsCount
                    anchors.top: checkinsCount.bottom
                    anchors.topMargin: 10
                    anchors.left: checkinsCount.right
                    anchors.leftMargin: 10
                    width: (parent.width - 40) / 3
                    height: 100
                    color: theme.colors.backgroundSand
                    smooth: true
                    radius: 5

                    Image {
                        y: 10
                        width: 64
                        height: 64
                        source: cache.get("https://playfoursquare.s3.amazonaws.com/badge/114/bookworm.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height - height - 2
                        color: theme.colors.textColorProfile
                        font.pixelSize: 20
                        text: details.userTipsCount + " " + "Tips"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            details.tips(userID);
                        }
                    }
                }
            }

            LineGreen {
                height: 30
                width: details.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: "YOU ARE #" + userLeadersboardRank
                visible: userRelationship == "self" && userLeadersboardRank > 0
            }

            Repeater {
                id: miniLeadersboard
                model: boardModel
                width: parent.width
                delegate: leaderBoardDelegate
                clip: true
                visible: userRelationship == "self" && userLeadersboardRank > 0
            }

        }
    }

    Component {
        id: leaderBoardDelegate

        EventBox {
            activeWhole: true
            width: miniLeadersboard.width

            userName: model.user
            //userShout:
            createdAt: model.shout

            Component.onCompleted: {
                userPhoto.photoUrl = model.photo
            }

            onAreaClicked: {
                details.openLeaderboard();
            }
        }
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: details
                x: parent.width
            }
        },
        State {
            name: "hiddenLeft"
            PropertyChanges {
                target: details
                x: -parent.width
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: details
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "shown"
            SequentialAnimation {
                PropertyAnimation {
                    target: details
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
                PropertyAction {
                    target: details
                    properties: "visible"
                    value: false
                }
            }
        },
        Transition {
            to: "shown"
            SequentialAnimation {
                PropertyAction {
                    target: details
                    properties: "visible"
                    value: true
                }
                PropertyAnimation {
                    target: details
                    properties: "x"
                    duration: 300
                    easing.type: "InOutQuad"
                }
            }
        }
    ]
}