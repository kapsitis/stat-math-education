// When the user clicks the marker, an info window opens.
// The maximum width of the info window is set to 200 pixels.

var data = {
    schools: [
        {
            "name": "Rīgas Valsts 1.ģimnāzija",
            "lat": 56.952936,
            "lng": 24.112265,
            "message": '<div id="content">' +
            '<div id="siteNotice">' +
            '</div>' +
            '<h2 id="firstHeading" class="firstHeading">Rīgas Valsts 1.ģimnāzija</h2>' +
            '<div id="bodyContent">' +
            '<p>223 darbi (147F, 76M)<br/>' +
            'Vid.punkti: 24.05; Dalība: 20.92%</p>' +
            '<p>Sk. <a href="http://r1g.edu.lv/v/index/">' +
            'http://r1g.edu.lv/v/index/</a></p>' +
            '</div>' +
            '</div>'
        },
        {
            "name": "Madonas Valsts ģimnāzija",
            "lat": 56.8576362,
            "lng": 26.2266878,
            "message": '<div id="content">' +
            '<div id="siteNotice">' +
            '</div>' +
            '<h2 id="firstHeading" class="firstHeading">Madonas Valsts ģimnāzija</h2>' +
            '<div id="bodyContent">' +
            '<p>20 darbi (12F, 8M)<br/>' +
            'Vid.punkti: 9.05; Dalība: 8.03%</p>' +
            '<p>Sk. <a href="http://www.madvg.lv/">' +
            'http://www.madvg.lv/</a></p>' +
            '</div>' +
            '</div>'
        },
        {
            "name": "Andreja Eglīša Ļaudonas vidusskola",
            "lat": 56.70381,
            "lng": 26.1968124,
            "message": '<div id="content">' +
            '<div id="siteNotice">' +
            '</div>' +
            '<h2 id="firstHeading" class="firstHeading">Andreja Eglīša Ļaudonas vidusskola</h2>' +
            '<div id="bodyContent">' +
            '<p>13 darbi (7F, 6M)<br/>' +
            'Vid.punkti: 9.08; Dalība: 11.11%</p>' +
            '<p>Sk. <a href="http://www.laudona.lv/vidusskola">' +
            'http://www.laudona.lv/vidusskola</a></p>' +
            '</div>' +
            '</div>'
        },
        {
            "name": "Bērzaunes pamatskola",
            "lat": 56.8122855,
            "lng": 26.0320376,
            "message": '<div id="content">' +
            '<div id="siteNotice">' +
            '</div>' +
            '<h2 id="firstHeading" class="firstHeading">Bērzaunes pamatskola</h2>' +
            '<div id="bodyContent">' +
            '<p>1 darbs (1M)<br/>' +
            'Vid.punkti: 2; Dalība: 1.89%</p>' +
            '<p>Sk. <a href="http://www.berzaunesskola.lv/">' +
            'http://www.berzaunesskola.lv/</a></p>' +
            '</div>' +
            '</div>'
        }
    ]
};

function initMap() {
    var theCenter = {lat: 56.9527866, lng: 24.1103476};
    var map = new google.maps.Map(document.getElementById('map'), {
        zoom: 8,
        center: theCenter
    });

    var infowindow = new google.maps.InfoWindow();
    var marker;
    var i;
    for (i = 0; i < data.schools.length; i++) {
        marker = new google.maps.Marker({
            position: {lat: data.schools[i].lat, lng: data.schools[i].lng},
            map: map,
            title: data.schools[i].name
        });

        google.maps.event.addListener(marker, 'click', (function(marker, i) {
            return function() {
                infowindow.setContent(data.schools[i].message);
                infowindow.open(map, marker);
            }
        })(marker, i));

    }
}