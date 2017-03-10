// When the user clicks the marker, an info window opens.
// The maximum width of the info window is set to 200 pixels.


function loadJSON(callback) {

    var xobj = new XMLHttpRequest();
    xobj.overrideMimeType("application/json");
    xobj.open('GET', 'js/schools.json', true); // Replace 'my_data' with the path to your file
    xobj.onreadystatechange = function () {
        if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but
            // simply returns undefined in asynchronous mode
            callback(xobj.responseText);
        }
    };
    xobj.send(null);
}


//var myJson = require('./schools.json');

function initMap() {
    var theCenter = {"lat": 56.952936, "lng": 24.112265 };
    var map = new google.maps.Map(document.getElementById('map'), {
        zoom: 8,
        center: theCenter
    });


    loadJSON(function(response) {
        var myJson = JSON.parse(response);
        var infowindow = new google.maps.InfoWindow();
        var marker;
        var i;
        for (i = 0; i < myJson.schools.length; i++) {
            //var pinColor = "FFFF00"
            //var pinImage = new google.maps.MarkerImage("http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|" + pinColor,
            //    new google.maps.Size(21, 34),
            //    new google.maps.Point(0,0),
            //    new google.maps.Point(10, 34));

            marker = new google.maps.Marker({
                position: {lat: myJson.schools[i].lat, lng: myJson.schools[i].lng},
                map: map,
                title: myJson.schools[i].name
            });

            //if (myJson.schools[i].activity < 0.02) {
            //    marker.setIcon('http://maps.google.com/mapfiles/ms/icons/purple-dot.png')
            //} else if (myJson.schools[i].activity < 0.04) {
            //    marker.setIcon('http://maps.google.com/mapfiles/ms/icons/blue-dot.png')
            //} else if (myJson.schools[i].activity < 0.06) {
            //    marker.setIcon('http://maps.google.com/mapfiles/ms/icons/green-dot.png')
            //} else if (myJson.schools[i].activity < 0.10) {
            //    marker.setIcon('http://maps.google.com/mapfiles/ms/icons/yellow-dot.png')
            //} else {
            //    marker.setIcon('http://maps.google.com/mapfiles/ms/icons/red-dot.png')
            //}

            if (myJson.schools[i].participants <= 2) {
                marker.setIcon('http://maps.google.com/mapfiles/ms/icons/purple-dot.png')
            } else if (myJson.schools[i].participants <= 5) {
                marker.setIcon('http://maps.google.com/mapfiles/ms/icons/blue-dot.png')
            } else if (myJson.schools[i].participants <= 10) {
                marker.setIcon('http://maps.google.com/mapfiles/ms/icons/green-dot.png')
            } else if (myJson.schools[i].participants <= 20) {
                marker.setIcon('http://maps.google.com/mapfiles/ms/icons/yellow-dot.png')
            } else {
                marker.setIcon('http://maps.google.com/mapfiles/ms/icons/red-dot.png')
            }



            google.maps.event.addListener(marker, 'click', (function (marker, i) {
                return function () {

                    var teacherStr = "";
                    var j;
                    for (j = 0; j < myJson.schools[i].skolotaji.length; j++) {
                        if (j > 0) {
                            teacherStr += "<br/>";
                        }
                        if (myJson.schools[i].skolotaji[j].teacherName == "") {
                            teacherStr += "<i>nav norādīts</i>" + ": " + myJson.schools[i].skolotaji[j].count;
                        } else {
                            teacherStr += myJson.schools[i].skolotaji[j].teacherName + ": " + myJson.schools[i].skolotaji[j].count;
                        }
                    }

                    infowindow.setContent(
                        '<div id="content">' +
                        '<div id="siteNotice">' +
                        '</div>' +
                        '<h2 id="firstHeading" class="firstHeading">' +
                        myJson.schools[i].name +
                        '</h2>' +
                        '<div id="bodyContent">' +
                        '<p>' +
                        ((myJson.schools[i].participants > 1) ?
                            ("" + myJson.schools[i].participants + " darbi (") :
                            ("" + myJson.schools[i].participants + " darbs (")) +
                        "" + myJson.schools[i].female + "F, " + myJson.schools[i].male + "M)" +
                        '<br/>' +
                        'Vid.punkti: ' +
                        myJson.schools[i].avgPoints +
                        '; Dalība: ' +
                        myJson.schools[i].activityStr +
                        '</p><u>Cik darbos norādīti skolotāji:</u><br/>' +
                        teacherStr +
                        '<p><a href="' +
                        myJson.schools[i].url +
                        '">Pilns pārskats</a></p>' +
                        '</div>' +
                        '</div>'
                    );
                    infowindow.open(map, marker);
                }
            })(marker, i));

        }
    });
}