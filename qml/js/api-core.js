/*
 * Foursquare API bindings
 */

.pragma library

api.log("loading api-core...");

api.MAX_NEARBY_DISTANCE = 100000; //100km
api.MAX_FEED_SIZE = 100;

var API_VERSION = "20120910";

/*
//Nelisquare V1
var CLIENT_ID = "4IFSW3ZXR4BRBXT3IIZMB13YPNGSIOK4ANEM0PP3T2CQQFWI";
var CALLBACK_URL = "http://nelisquare.substanceofcode.com/callback.php";
*/

//Nelisquare V2
var CLIENT_ID = "SF1OZJLHW0EIP5IKCSAQTNCSYECFJ3QZMCYO31BZMLRVF3WH";
var CALLBACK_URL = "https://nelisquare.herokuapp.com/authcallback";

var AUTHENTICATE_URL = "https://foursquare.com/oauth2/authenticate" +
    "?client_id=" + CLIENT_ID +
    "&response_type=token" +
    "&display=touch" +
    "&v=" + API_VERSION +
    "&redirect_uri=" + CALLBACK_URL;

var API_URL = "https://api.foursquare.com/v2/";

var defaultVenueIcon = {"prefix":"https://foursquare.com/img/categories_v2/none_","suffix":".png"}

/** Parse parameter from given URL */
function parseAuth(data, parameterName) {
    var parameterIndex = data.indexOf(parameterName + "=");
    if(parameterIndex<0) {
        // We didn't find parameter
        return undefined;
    }
    var equalIndex = data.indexOf("=", parameterIndex);
    if(equalIndex<0) {
        return undefined;
    }

    //var lineBreakIndex = data.indexOf("\n", equalIndex+1)

    var value = "";
    value = data.substring(equalIndex+1);
    return value;
}


api.request = function(method, url, page, callback) {
    api.log(method + " " + url.replace(/oauth\_token\=([A-Z0-9]+).*\&v\=.*/gm,""));
    url = API_URL + url;

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200) {
                page.show_error("API returned " + status + " " + doc.statusText);
            }
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.status == 200) {
                var data;
                var contentType = doc.getResponseHeader("Content-Type");
                data = doc.responseText;
                callback(data,page);
            } else {
                if (doc.status == 0) {
                    page.show_error("Network connection error");
                } else {
                    page.show_error("General error: " + doc.status);
                }
            }
        }
    }

    doc.open(method, url);
    doc.send();
}

api.process = function(response, page) {
    var data = eval("[" + response + "]")[0];
    var meta = data.meta;
    if (meta.code != 200) {
        if (page!==undefined) {
            page.show_error("<span>API Error: " + meta.code
                            + "<br/>Error type: " + meta.errorType
                            + "<br/>" + meta.errorDetail + "<br/></span>");
        }
    }
    //console.log("DATA: " + JSON.stringify(data));
    var notifications = data.notifications;
    if (notifications!==undefined){
        //console.log("NOTIFICATIONS: " + JSON.stringify(notifications));
        notifications.forEach(function(notification) {
                if (parse(notification.type) == "notificationTray") {
                    if (page !== undefined)
                        page.updateNotificationCount(notification.item.unreadCount);
                }
            });
    }
    return data.response;
}

function doNothing(response,page) {
    // Nothing...
    api.process(response, page);
}

function setPositionSource(source) {
    api.debug("setting position source");
    api.positionSource = source;
}

function getLocationParameter() {
    var lat = api.positionSource.position.coordinate.latitude;
    var lon = api.positionSource.position.coordinate.longitude;
    var result = "ll=" + lat + "," + lon;
    api.debug("location: " + result);
    return result;
}

function setAccessToken(token) {
    //api.debug("SET TOKEN: " + token);
    api.accessToken = token;
}
function getAccessTokenParameter() {
    var token = api.accessToken;
    //api.debug("GET TOKEN: " + token);
    return "oauth_token=" + token + "&v=" + API_VERSION;
}
