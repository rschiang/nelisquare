import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2

import "components"
import "js/api.js" as Api

PageStackWindow {
    id: appWindow
    property bool windowActive: Qt.application.active
    property string lastNotiCount: "0"
    property int notificationsCount: 0

    property alias stack: tabgroup.currentTab;

    showToolBar: tabgroup.currentTab !== tabLogin || tabLogin.depth > 1
    showStatusBar: inPortrait

    onWindowActiveChanged: {
        console.log("active: " + windowActive);

        if (configuration.gpsAllow !== "1") {
            positionSource.active = false;
            return;
        }
        if (!windowActive) {
            if (positionSource.position.latitudeValid) {
                timerGPSUnlock.start();
            } else {
                positionSource.active = windowActive;
            }
        } else {
            timerGPSUnlock.stop();
            positionSource.active = windowActive;
        }
    }    

    Component.onCompleted: {
        if ( configuration.platform === "maemo") {
            appWindow.allowSwitch  = false;
            appWindow.allowClose = false;
        }
    }

    initialPage: mainPage

    Page {
        id: mainPage
        //tools: commonTools
        tools: stack.currentPage !== null ? stack.currentPage.tools : null
        onToolsChanged: {
            if (pageStack) {
                pageStack.toolBar.tools = tools;
            }
        }

        TabGroup {
            id: tabgroup
            currentTab: tabLogin
            anchors.fill: parent
            /*anchors {
                top: pageHeader.bottom;
                left: parent.left;
                right: parent.right;
                bottom: parent.bottom;
            }*/
            property variant lastTab

            onCurrentTabChanged: {
                if (currentTab.depth === 0) {
                    currentTab.load();
                }
            }

            PageStack {
                id: tabFeed
                function load() {
                    tabFeed.push(Qt.resolvedUrl("pages/FriendsFeed.qml"))
                }
            }

            PageStack {
                id: tabVenues
                function load() {
                    tabVenues.push(Qt.resolvedUrl("pages/VenuesList.qml"))
                }
            }

            PageStack {
                id: tabMe
                function load() {
                    tabMe.push(Qt.resolvedUrl("pages/User.qml"),{"userID":"self"})
                }
            }

            PageStack {
                id: tabLogin
                function load() {
                    tabLogin.clear();
                    tabLogin.push(Qt.resolvedUrl("pages/Welcome.qml"),{"newuser":true},true);
                }
            }
        }

        NotificationDialog {
            id: notificationDialog
            z: 20
            width: parent.width
            state: "hidden"
            onClose: {
                /* TODO: this doesnt work atm. Should be deleted
                if (objectID != "") {
                    objectType = "";
                    objectID = "";
                    if(objectType=="checkin") {
                        stack.push(Qt.resolvedUrl("pages/Checkin.qml"),{"checkinID":objectID});
                    }
                }*/
                notificationDialog.state = "hidden";
            }
        }
    }

    Component{
        id: dummyMenu

        Menu {
            MenuLayout {
                MenuItem {
                    text: qsTr("Check updates")
                    onClicked: {
                        configuration.getupdates();
                    }
                }
                MenuItem {
                    text: qsTr("Settings")
                    onClicked: {
                        stack.push(Qt.resolvedUrl("pages/Settings.qml"));
                    }
                }
                MenuItem {
                    text: qsTr("Exit")
                    onClicked: {
                        windowHelper.disableSwype(false);
                        Qt.quit();
                    }
                }
            }
        }
    }

    ToolBarLayout {
        id: commonTools
        ToolIcon {
            iconId: stack.depth > 1 ? "toolbar-back" : "toolbar-back-dimmed"//toolbar-refresh"
            //iconId: "toolbar-back"
            onClicked: {
                if (stack.depth > 1)
                    stack.pop();
            }
        }
        ButtonRow {
            style: TabButtonStyle {}

            TabButtonIcon {
                platformIconId: "toolbar-home"
                tab: tabFeed
                onClicked: popToTop(tabFeed);
            }
            TabButtonIcon {
                //platformIconId: "toolbar-venues" //TODO: add icons to theme extension
                iconSource: "icons/icon-m-toolbar-venues".concat(theme.inverted ? "-white" : "").concat(".png")
                tab: tabVenues
                onClicked: popToTop(tabVenues);
            }
            TabButtonIcon {
                platformIconId: "toolbar-contact"
                tab: tabMe
                onClicked: popToTop(tabMe);
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                if (stack.currentPage.pageMenu !== undefined) {
                    stack.currentPage.pageMenu.open();
                } else {
                    dummyMenu.createObject(mainPage).open();
                }
            }
        }
    }

    Configuration {
        id: configuration

        onAccessTokenChanged: {
            if(accessToken.length>0) {
                openStartPage();
                tabLogin.clear();
                windowHelper.disableSwype(configuration.disableSwypedown === "1");
            } else {
                tabFeed.clear();
                tabVenues.clear();
                tabMe.clear();
                tabLogin.load();
                tabgroup.currentTab = tabLogin;
                windowHelper.disableSwype(false);
            }
        }
    }

    ThemeLoader {
        id: mytheme

        onInvertedChanged: {
            Api.api.inverted = inverted;
        }
    }

    Timer {
        id: timerGPSUnlock
        interval: configuration.gpsUplockTime * 1000;
        repeat: false
        onTriggered: {
            positionSource.active = appWindow.windowActive;
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: false
    }

    function sendDebugInfo(object) {
        stack.push(Qt.resolvedUrl("pages/DebugSubmit.qml"), {"content": object});
    }

    function openStartPage() {
        switch(configuration.startPage) {
        case "self":
            tabgroup.currentTab = tabMe;
            break;
        case "venues":
            tabgroup.currentTab = tabVenues;
            break;
        case "feed":
        default:
            tabgroup.currentTab = tabFeed;
            break;
        }
    }

    function popToTop(tab) {
        if (tabgroup.lastTab === tab) {
            if (tab.depth === 1) {
                if (tab.currentPage.updateView !== undefined)
                    tab.currentPage.updateView();
            } else {
                while (tab.depth > 1) {
                    tab.pop(tab.depth > 2);
                }
            }
        }
        tabgroup.lastTab = tab;
    }

    function processUINotification(id) {
        stack.push(Qt.resolvedUrl("pages/Notifications.qml"));
    }

    function processURI(url) {
        console.log("uri: " + url);
        var params = url.split("/");
        var type = params[0];
        var id = params[1];
        popToTop(tabgroup.currentTab);
        switch(type) {
        case "start":
            openStartPage();
            if (id === "top") {
                popToTop(tabgroup.currentTab);
            }
            break;
        case "friend":
            stack.push(Qt.resolvedUrl("pages/User.qml"),{"userID":id});
            break;
        case "checkin":
            stack.push(Qt.resolvedUrl("pages/Checkin.qml"),{"checkinID":id});
            break;
        case "savetip":
        case "tip":
            stack.push(Qt.resolvedUrl("pages/TipPage.qml"), {"tipID":id});
            break;
        case "savevenue":
        case "likevenue":
            stack.push(Qt.resolvedUrl("pages/Venue.qml"), {"venueID":id});
            break;
        //TODO: ? how to treat badges?
        case "awardbadge":
        //TODO: implement theese as pages will be available
        case "installplugin":
        case "likepage":
        case "pageupdate":
        case "likepageupdate":
        case "savelist":
        default:
            console.log("Unimplemented feed callback for content: " + type);
            break;
        }

    }

    function onCacheUpdated(callbackObject, status, url) {
        //console.log("Cache update callback: type: " + typeof(callbackObject) + " status: " + status + " url: " + url );
        try {
            if (typeof(callbackObject) === "function") {
                //console.log("funtion!");
                callbackObject(status,url);
            } else if (typeof(callbackObject) === "object") {
                //console.log("object!");
                if (callbackObject.cacheCallback !== undefined) {
                    callbackObject.cacheCallback(status,url);
                } else {
                    console.log("object callback is undefined!");
                }
            } else if (typeof(callbackObject) === "string") {
                //console.log("string!");
                var obj = Api.objs.get(callbackObject);
                if (obj.cacheCallback !== undefined) {
                    obj.cacheCallback(status,url);
                } else {
                    console.log("object callback is undefined!");
                }
                Api.objs.remove(callbackObject);
            } else {
                console.log("type is: " + typeof(callbackObject));
            }
        } catch (err) {
            console.log("Cache callback error: " + err + " type: " + typeof(callbackObject) + " value: " + JSON.stringify(callbackObject) );
        }
    }

    function reloadUI() {
        platformUtils.clearFeed();
        tabLogin.clear();
        tabFeed.clear();
        tabVenues.clear();
        tabMe.clear();
        tabgroup.currentTab.load();
    }

    function onLanguageChanged(language) {
        reloadUI();
    }

    function onPictureUploaded(response, page) {
        Api.photos.parseAddPhoto(response, page);
    }

    function onMolomeInfoUpdate(present,installed) {
        configuration.molome_present = present;
        configuration.molome_installed = installed;
    }

    function onMolomePhoto(state, photoUrl) {
        if (stack.currentPage.molomePhoto !== undefined) {
            stack.currentPage.molomePhoto(state, photoUrl);
        }
    }

    function onLockOrientation(value) {
        if (value === "auto") {
            mainPage.orientationLock = PageOrientation.Automatic
        } else if (value === "landscape") {
            mainPage.orientationLock = PageOrientation.LockLandscape
        } else if (value === "portrait") {
            mainPage.orientationLock = PageOrientation.LockPortrait
        }
    }

    //TODO: remove to single "Sheet"
    UpdateDialog {
        id: updateDialog
        z: 30
    }

    QueryDialog  {
        id: locationAllowDialog
        icon: "image://theme/icon-m-common-location-selected"
        titleText: qsTr("Location data")
        message: qsTr("Nelisquare requires use of user location data. Data is needed to make geo-location services work properly.")
        acceptButtonText: qsTr("Allow")
        rejectButtonText: qsTr("Deny")
        onAccepted: {
            configuration.settingChanged("settings.gpsallow","1");
        }
        onRejected: {
            configuration.settingChanged("settings.gpsallow","0");
        }
    }

    QueryDialog  {
        id: pushNotificationDialog
        icon: "image://theme/icon-m-settings-notification"
        titleText: qsTr("Push notifications")
        message: qsTr("Incoming push notifications are not supported at this version and are disabled by default.<br/><br/>You will be promted again when they will be available at future versions.")
        onAccepted: {
            configuration.settingChanged("settings.push.enabled","0");
        }
        acceptButtonText: qsTr("OK")
        /*buttons: ButtonRow {
            style: ButtonStyle { }
            anchors.horizontalCenter: parent.horizontalCenter
            Button { text: "OK"; onClicked: pushNotificationDialog.accept(); }
        }*/
    }
}
