function simpleMap(options) {
  var map_el = document.querySelector(options.selector),
      coords = {
        lat: options.lat,
        lng: options.lng
      }, marker;

  if (!!map_el) {
    marker = new google.maps.Marker({
      position: coords,
      map: new google.maps.Map(map_el, { zoom: 12, center: coords }),
      title: options.name || 'Location'
    });
  }
}
