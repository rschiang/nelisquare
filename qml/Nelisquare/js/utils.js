
function makeTime(date) {
    var pretty = prettyDate(new Date(parseInt(date,10)*1000));
    return pretty;
}

function prettyDate(date){
    try {
        var diff = (((new Date()).getTime() - date.getTime()) / 1000);
        var day_diff = Math.floor(diff / 86400);

        if ( isNaN(day_diff) || day_diff >= 31 ) {
            //console.log("Days: " + day_diff);
            return "some time ago";
        } else if (day_diff < 0) {
            //console.log("day_diff: " + day_diff);
            return "just now";
        }

        return day_diff == 0 && (
                    diff < 60 && "just now" ||
                    diff < 120 && "1 minute ago" ||
                    diff < 3600 && Math.floor( diff / 60 ) + " min ago" ||
                    diff < 7200 && "1 hour ago" ||
                    diff < 86400 && Math.floor( diff / 3600 ) + " hours ago") ||
                day_diff == 1 && "Yesterday" ||
                day_diff < 7 && day_diff + " days ago" ||
                day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago";
        day_diff >= 31 && Math.ceil( day_diff / 30 ) + " months ago";
    } catch(err) {
        //console.log("Error: " + err);
        return "some time ago";
    }
}

// 2011-01-24T18:48:00Z
function parseDate(stamp)
{
    try {
        //console.log("stamp: " + stamp);
        var parts = stamp.split("T");
        var day;
        var time;
        var hours;
        var minutes;
        var seconds = 0;
        var year;
        var month;

        var dates = parts[0].split("-");
        year = parseInt(dates[0]);
        month = parseInt(dates[1])-1;
        day = parseInt(dates[2]);

        var times = parts[1].split(":");
        hours = parseInt(times[0]);
        minutes = parseInt(times[1]);

        var dt = new Date();
        dt.setUTCDate(day);
        dt.setYear(year);
        dt.setUTCMonth(month);
        dt.setUTCHours(hours);
        dt.setUTCMinutes(minutes);
        dt.setUTCSeconds(seconds);

        //console.log("day: " + day + " year: " + year + " month " + month + " hour " + hours);

        return dt;
    } catch(err) {
        //console.log("Error while parsing date: " + err);
        return new Date();
    }
}

function stringToBytes ( str ) {
  var ch, st, re = [];
  for (var i = 0; i < str.length; i++ ) {
    ch = str.charCodeAt(i);  // get char
    st = [];                 // set up "stack"
    do {
      st.push( ch & 0xFF );  // push byte to stack
      ch = ch >> 8;          // shift value down by 1 byte
    }
    while ( ch );
    // add stack contents to result
    // done because chars have "wrong" endianness
    re = re.concat( st.reverse() );
  }
  // return an array of bytes
  return re;
}
