$(function () {
  var current_location, markers = [],
      labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      default_map_options = {
        zoom: 9,
        center: { lat: 39.5572303, lng: -75.7506341 }
      },
      $results = $('#results'),
      map_el = document.getElementById('map'),
      map = new google.maps.Map(map_el, default_map_options);

  // create a new marker and add it to the existing map
  function add_marker(coords, title, data) {
    data.label = labels[markers.length % labels.length];
    data.visible = true;
    data.marker = new google.maps.Marker({
      map: map,
      position: coords,
      title: title,
      label: data.label
    });
    data.marker.addListener('click', function () {
      var $this = $(this);

      markers.forEach(function (el, i) {
        el.visible = markers[i].visible = (data.label === el.label) || !el.visible;
        $results.find(`.school-list-item[data-label="${el.label}"]`).toggle(el.visible)
        el.marker.setMap(el.visible ? map : null);
      });
    })
    markers.push(data);
    return data;
  }

  // remove all markers
  function clear_markers() {
    markers.forEach((m) => m.marker.setMap(null));
    markers = [];
    $results.html('');
  }

  // reset the map to a new location
  function reset_current_location(place) {
    clear_markers();

    if (current_location) {
      current_location.marker.setMap(null);
    }

    current_location = {
      place: place,
      coords: {
        lat: place.geometry.location.lat(),
        lng: place.geometry.location.lng()
      }
    };
    current_location.marker = new google.maps.Marker({
      map: map,
      name: place.name,
      position: current_location.coords
    });

    map.setCenter(current_location.marker.position);
    map.setZoom(11);
  }

  // zoom in the map to fit all markers
  function zoom_to_fit() {
    var bounds = new google.maps.LatLngBounds();
    bounds.extend(current_location.marker.getPosition());
    markers.forEach((m) => bounds.extend(m.marker.getPosition()));
    map.fitBounds(bounds);
    map.setZoom(map.getZoom() - 0.5);
  }

  // place a marker on the map and include school in list
  function add_feature(data) {
    marker = add_marker({
        lng: data.geometry.coordinates[0],
        lat: data.geometry.coordinates[1]
      },
      data.properties.school.name,
      data
    );
    zoom_to_fit();
    $results.append(
      $(`<div class="school-list-item" data-label="${marker.label}"></div>`).append(
        `<h3>${marker.label}</h3>`,
        $('<div></div>').append(
          `<div><small>School:</small><strong>${data.properties.school.name}</strong></div>`,
          `<div><small>District:</small><strong>${data.properties.school.district.name}</strong></div>`
        )
      )
    );
  }

  // setup autocompletion as address is entered
  $('input.place-autocomplete').each(function () {
    var autocomplete = new google.maps.places.Autocomplete(this, {});

    // rerender the map with centered on the new location
    autocomplete.addListener('place_changed', function () {
      var place = autocomplete.getPlace();
      reset_current_location(place);
      $('button[data-require-place]').each(function () { this.disabled = false; });
    });

    // don't submit the whole form if the user hits enter on the autocomplete
    google.maps.event.addDomListener(this, 'keydown', function (e) {
      if (e.keyCode === 13) {
        e.preventDefault();
      }
    });
  });

  // automatically perform a feeder school lookup when the grade is select
  $('#grade_level').on('change', function () {
    $('#resolve_feeder_pattern').trigger('click');
  });

  // show the feeder school for the selected grade at the provided address
  $('#resolve_feeder_pattern').on('click', function () {
    if (!current_location) {
      return; // guard: home address hasn't been entered yet.
    }

    clear_markers();

    $.ajax({
      url: '/lookup',
      dataType: 'json',
      data: {
        grade_level: $('#grade_level').val(),
        lat: current_location.coords.lat,
        lon: current_location.coords.lng
      }
    })
      .done(function (data) {
        var found = false;
        if (data) {
          if (data.type === 'Feature') {
            add_feature(data);
            found = true;
          } else if (data.type === 'FeatureCollection') {
            data.features.forEach((feature) => add_feature(feature));
            found = true;
          }
        }

        if (found === false) {
          // This is an edge case trap
          $results.html('<em style="color:#ff6347">No results found.</em>');
        }
      })
      .fail(function (error) {
        if (error.status == 404) {
          $results.html('<em>No schools located for given information.</em>');
        } else {
          $results.html('<em style="color:#a22;">An error communicating with the server occurred.</em>');
        }
      });
  });

  // automatically perform a radius lookup when the radius is select
  $('#radius').on('change', function () {
    $('#resolve_radius').trigger('click');
  });

  // Show all schools with a radius of the provided address
  $('#resolve_radius').on('click', function () {
    if (!current_location) {
      return; // guard: home address hasn't been entered yet.
    }

    clear_markers();

    $.ajax({
      url: '/radius',
      dataType: 'json',
      data: {
        radius: parseFloat($('#radius').val()) * 1609.344,
        lat: current_location.coords.lat,
        lon: current_location.coords.lng
      }
    })
      .done(function (data) {
        if (data && data.type === 'FeatureCollection') {
          data.features.forEach((feature) => add_feature(feature));
        } else {
          $results.html('<em style="color:#ff6347">Unexpected data received from server..</em>');
        }
      })
      .fail(function (error) {
        if (error.status == 404) {
          $results.html('<em>No schools located for given information.</em>');
        } else {
          $results.html('<em style="color:#a22;">An error communicating with the server occurred.</em>');
        }
      });
  });
});
