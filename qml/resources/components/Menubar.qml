import Qt 4.7
import "."

Rectangle {
    id: menubar
    height: 70
    anchors{
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }
    color: theme.colors.backgroundMenubar

    MouseArea {
        anchors.fill: parent
    }

    Flow {
        id: menubarToolbar
        //width: menubar.width
        anchors.horizontalCenter: parent.horizontalCenter
        height: menubar.height
        spacing: 15

        ToolbarTextButton {
            id: backwardsButton
            label: "BACK"
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            shown: pageStack.depth > 1
            onClicked: {
                pageStack.pop();
            }
        }

        ToolbarTextButton {
            label: "FEED"
            selected: topWindowType == "FriendsFeed"
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            onClicked: {
                window.showFriendsFeed();
            }
        }

        ToolbarTextButton {
            label: "PLACES"
            selected: topWindowType == "VenuesList" && WM.topWindow().params.id !== "todolist"
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            onClicked: {
                window.showVenueList("");
            }
        }

        ToolbarTextButton {
            label: "LISTS"
            selected: topWindowType == "VenuesList" && WM.topWindow().params.id === "todolist"
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            onClicked: {
                window.showVenueList("todolist");
            }
        }

        ToolbarTextButton {
            label: "ME"
            selected: topWindowType === "User" && WM.topWindow().params.id === "self"
            colorActive: theme.colors.textButtonTextMenu
            colorInactive: theme.colors.textButtonTextMenuInactive
            onClicked: {
                window.showUserPage("self");
            }
        }

    }

    state: window.isPortrait ? "bottom" : "right"

    states: [
        State {
            name: "bottom"
            PropertyChanges {
                target: menubar
                height: 70
                width: parent.width
                y: parent.height - menubar.height
                x: 0
            }
            PropertyChanges {
                target: menubarToolbar
                y: 5
                x: 5//(menubar.width - backwardsButton.width*5 - 4*menubarToolbar.spacing)/2
                width: undefined
            }
        },
        State {
            name: "right"
            PropertyChanges {
                target: menubar
                width: 100
                height: parent.height - toolbar.height
                x: parent.width - width
                y: toolbar.height
            }
            PropertyChanges {
                target: menubarToolbar
                y: 5//(menubar.height - backwardsButton.height*5 - 4*menubarToolbar.spacing)/2
                x: 5
                width: menubar.width
            }
        }
    ]
}