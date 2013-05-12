/*
 *
 */
.pragma library

api.log("loading api-feed...");

var feed = new ApiObject();
//feed.debuglevel = 2;

feed.loadFriendsFeed = function(page, history) {
    //activities/recent activities/recent?afterMarker=50ade891e4b0892bb7343597
    var url = "activities/recent?"
    if (page.isUpdating)
        return;
    page.isUpdating = true;
    page.waiting_show();

    if (history!==undefined) {
        url += "beforeMarker=" + page.trailingMarker + "&";
    } else {
        if (page.leadingMarker !== "") {
            url += "afterMarker=" + page.leadingMarker + "&";
        }
    }

    if (page.nearbyPressed) {
        url += getLocationParameter() + "&";
    }

    url += "limit=" + page.batchSize + "&" +getAccessTokenParameter();
    api.request("GET", url, page, function(response,page) {
                     feed.parseFriendsFeed(response,page,history);
                 });

    if (history===undefined && page.lastUpdateTime!=="0") {
        //activities/updates ?afterTimestamp=0 & updatesAfterMarker=50ade891e4b0892bb7343597
        var url2 = "activities/updates?afterTimestamp=" + page.lastUpdateTime
        url2 += "&updatesAfterMarker=" + page.trailingMarker; //page.leadingMarker;
        url2 += "&" +getAccessTokenParameter()
        api.request("GET", url2, page, feed.parseFriendsFeedUpdate);
    }
}

feed.parseFriendsFeedUpdate = function(response, page) {
    var data = api.process(response, page);
    feed.log("UPDATES: " + JSON.stringify(data));
    data.updates.items.forEach(
        function(update){
            if (update.type === "checkin") {
                for (var i=0;i<page.friendsCheckinsModel.count;i++) {
                    if (page.friendsCheckinsModel.get(i).id !== update.id)
                        continue;
                    feed.log("FOUND CHECKIN in MODEL: " + update.id);
                    page.updateItem(i,
                        {
                        "commentsCount": update.comments.count,
                        "comments": update.comments.items,
                        "likesCount": update.likes.count
                        }
                    );

                    break;
                }
            } else {
                feed.log("UPDATE TYPE: " + update.type);
                feed.log("UPDATE CONTENT: " + JSON.stringify(update));
            }
        });
}

feed.parseFriendsFeed = function(response, page, history) {
    page.waiting_hide();
    page.isUpdating = false;
    var data = api.process(response, page);
    var activities = data.activities;

    var count = 0;
    var updateTime = page.lastUpdateTime;
    var updating = (updateTime !== "0");

    if (page.leadingMarker === "") {
        page.friendsCheckinsModel.clear();
    }

    if (history !== undefined || !updating) {
        feed.debug("MORE DATA: Updated: "+ activities.moreData);
        page.moreData = activities.moreData;
    }
    if (activities.leadingMarker > page.leadingMarker)
        page.leadingMarker = activities.leadingMarker;
    if (activities.trailingMarker < page.trailingMarker || page.trailingMarker === "")
        page.trailingMarker = activities.trailingMarker;

    var feedObjParser = function(object) {
        var append = (!updating || history!==undefined);

        var timeObj = object;
        if (timeObj.object !== undefined)
            timeObj=timeObj.object;
        if (updateTime <= timeObj.createdAt)
            updateTime = timeObj.createdAt;
        if (object.type === "checkin") {
            if (feed.feedObjParserCheckin(page, object.object, append, count))
                count++;
        } else if (object.type === "photo") {
            feed.feedObjParserPhoto(page,object.object);
        } else if (object.type === "friend" ) {
            feed.feedObjParserFriend(page, object, append, count);
            count++;
        } else if (object.type === "tip") {
            feed.feedObjParserTip(page, object, append, count);
            count++;
        } else {
            //un implemented content types goes here
            feed.log("CONTENT TYPE: " + object.type);
            feed.log("CONTENT VALUE: " + JSON.stringify(object));
            var itemtest = {
                "type": object.type,
                "content": {
                    "type": object.type
                }
            }
            page.addItem(itemtest);
        }
    }

    activities.items.forEach(
    function(activity){
        feed.debug("ACTIVITY: " + JSON.stringify(activity));
        if (activity.type === "create") {
            var content = activity.content;

            if (content.type === "aggregation") {
                content.object.items.forEach(function(item) {
                    feedObjParser(item);
                });
            } else {
                feedObjParser(content);
            }
        } else if (activity.type === "friend") {
            feedObjParser(activity);
        } else if (activity.type === "like") {
            feedObjParser(activity.content);
        } else {
            //un implemented events goes here
            var itemtest = {
                "type": activity.type,
                "content": {
                    "type": activity.type
                }
            }
            page.addItem(itemtest);
            feed.log("ACTIVITY TYPE: " + activity.type);
            feed.debug("ACTIVITY CONTENT: " + JSON.stringify(activity));
            return;
        }
    });

    if (!updating) {
        page.timerFeedUpdate.restart();
    } else {
        //Limit all checkins //TODO: Make options at settings of feed length
        if (history===undefined) {
            var currentsize = page.friendsCheckinsModel.count;
            for (var i=api.MAX_FEED_SIZE;i<currentsize;i++){
                page.removeItem(api.MAX_FEED_SIZE);
                page.moreData = true;
            }
            if (currentsize>(maxsize-1))
                page.trailingMarker = page.friendsCheckinsModel.get(maxsize-1).id;
        }
    }
    page.lastUpdateTime = updateTime;
}

feed.feedObjParserCheckin = function(page, checkin, append, count) {
    var result = true;
    var userName = makeUserName(checkin.user);
    var venueName = "";
    var venueID = "";
    var venueDistance = undefined;
    if(checkin.venue!==undefined) {
        venueName = checkin.venue.name;
        venueID = checkin.venue.id;
        venueDistance = checkin.venue.location.distance;
    }
    var venuePhoto = "";
    if (checkin.photos.count > 0) {
        venuePhoto = thumbnailPhoto(checkin.photos.items[0], 300, 300);
    }
    if (venueDistance === undefined || venueDistance < api.MAX_NEARBY_DISTANCE) {
        var item = {
            "type": "checkin",
            "content": {
                "id": checkin.id,
                "type": "checkin",
                "shout": parse(checkin.shout),
                "user": userName,
                "userID": checkin.user.id,
                "mayor": parse(checkin.isMayor),
                "photo": thumbnailPhoto(checkin.user.photo, 100),
                "venueID": venueID,
                "venueName": venueName,
                "createdAt": makeTime(checkin.createdAt),
                "timestamp": checkin.createdAt,
                "venuePhoto": venuePhoto,
                "commentsCount": checkin.comments.count,
                "comments": checkin.comments.items,
                "likesCount": checkin.likes.count,
                "photosCount": checkin.photos.count
            }
        };
        if (append) {
            feed.debug("adding checkin at end");
            page.addItem(item);
        } else {
            page.addItem(item,count);
            feed.debug("adding checkin at head");
        }
        result = true;
    } else if (venueDistance !== undefined) {
        result = false;
    }
    return result;
}

feed.feedObjParserPhoto = function(page, photo) {
    feed.debug("NEW PHOTO: " + JSON.stringify(photo) );
    for (var i=0;i<page.friendsCheckinsModel.count;i++) {
        if (page.friendsCheckinsModel.get(i).id !== photo.checkin.id)
            continue;
        feed.log("UPDATE CHECKIN PHOTO: " + photo.checkin.id);
        var photosCount = page.friendsCheckinsModel.get(i).photosCount;
        photosCount++;
        page.updateItem(i,
            {
            "venuePhoto": thumbnailPhoto(photo,300,300),
            "photosCount": photosCount,
            }
        );

        break;
    }
}

feed.feedObjParserFriend = function(page, friend, append, count) {
    if (friend.content.type === "aggregation") {
        //TODO: change if aggregation will be enabled
        feed.log("FRIEND AGGREGATION!")
        feed.debug("FRIEND AGGREGATION: " + JSON.stringify(friend));
        friend.content.object.id = friend.thumbnails[0].id;
    }
    feed.debug("FRIEND CONTENT: " + JSON.stringify(friend));
    var item = {
        "type": friend.type,
        "content": {
            "type": friend.type,
            "id": friend.content.object.id,
            "user": friend.summary.text,
            "createdAt": makeTime(friend.createdAt),
            "timestamp": friend.createdAt,
        }
    };
    if (append) {
        feed.debug("adding friend at end");
        page.addItem(item);
    } else {
        feed.debug("adding friend at head");
        page.addItem(item,count);
    }
}

feed.feedObjParserTip = function(page, object, append, count) {
            var tip = object.object;
            feed.debug("TIP CONTENT: " + JSON.stringify(tip));
            var icon = "";
            if (tip.venue.categories[0] !== undefined)
                icon = parseIcon(tip.venue.categories[0].icon);
            else
                icon = parseIcon(defaultVenueIcon);
            //TODO: somehow add an "Username liked the tip"
            var item = {
                "type": "tip",
                "content": {
                    "type": "tip",
                    "id": tip.venue.id,
                    "shout": tip.text,
                    "venueName": tip.venue.name,
                    "photo": icon,
                    "likesCount": tip.likes.count,
                    "venuePhoto": thumbnailPhoto(tip.photo, 300, 300),
                    "createdAt": makeTime(tip.createdAt),
                    "timestamp": tip.createdAt,
                }
            }
            if (append) {
                feed.debug("adding friend at end");
                page.addItem(item);
            } else {
                feed.debug("adding friend at head");
                page.addItem(item,count);
            }
};

