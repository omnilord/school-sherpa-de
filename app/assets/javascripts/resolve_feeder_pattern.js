$(function () {
  var current_location, marker, map;

  function addMarker(coords, title) {
   return new google.maps.Marker({
      position: coords,
      map: map,
      title: title
    });
  }

  function zoomToFit(markers) {
    var bounds = new google.maps.LatLngBounds();
    markers.forEach((m) => bounds.extend(m.getPosition()));
    map.fitBounds(bounds);
    map.setZoom(map.getZoom() - 0.5);
  }

  function setMap(options) {
    var map_el = document.querySelector(options.selector),
        coords = {
          lat: options.lat,
          lng: options.lng
        }, marker;

    if (!!map_el) {
      map = map || new google.maps.Map(map_el, { zoom: 12, center: coords });
      if (current_location) {
        current_location.setMap(null);
      }
      current_location = addMarker(coords, options.name || 'Location');
      map.setCenter(current_location.position);
      map.setZoom(12);
    }
  }

  function PlaceAutocomplete(el, opts, callback) {
    var autocomplete = new google.maps.places.Autocomplete(el, {});
    autocomplete.addListener('place_changed', function () {
      var place = autocomplete.getPlace(),
          cityComponent = place.address_components.find(function (c) {
            return c.types.indexOf('locality') >= 0;
          }),
          countyComponent = place.address_components.find(function (c) {
            return c.types.indexOf('administrative_area_level_2') >= 0;
          }),
          stateComponent = place.address_components.find(function (c) {
            return c.types.indexOf('administrative_area_level_1') >= 0;
          }),
          zipComponent = place.address_components.find(function (c) {
            return c.types.indexOf('postal_code') >= 0;
          });

      if (place.geometry && place.geometry.location) {
        $(opts.fillLat).val(place.geometry.location.lat());
        $(opts.fillLng).val(place.geometry.location.lng());
      } else {
        $(opts.fillLat).val('');
        $(opts.fillLng).val('');
      }

      $(opts.fillPlaceId).val(place.place_id || '');
      $(opts.fillName).val(place.name || '');
      $(opts.fillAddress).val(place.formatted_address || '');
      $(opts.fillCity).val(cityComponent ? cityComponent.long_name : '');
      $(opts.fillCounty).val(countyComponent ? countyComponent.long_name : '');
      $(opts.fillZip).val(zipComponent ? zipComponent.long_name : '');
      $(opts.fillState).val(stateComponent ? stateComponent.long_name : '');

      if (place.formatted_phone_number && $(opts.fillPhone).val().length === 0) {
        $(opts.fillPhone).val(place.formatted_phone_number);
      }

      if (callback) {
        callback(place);
      }
    })

    // don't submit the whole form if the user hits enter on the autocomplete
    google.maps.event.addDomListener(el, 'keydown', function (e) {
      if (e.keyCode === 13) {
        e.preventDefault();
      }
    });
  };

  $('input.place-autocomplete').each(function () {
    var $el = $(this),
        fillers = {
          fillName: $el.data('name'),
          fillAddress: $el.data('address'),
          fillPhone: $el.data('phone'),
          fillLat: $el.data('lat'),
          fillLng: $el.data('lng'),
          fillPlaceId: $el.data('placeid'),
          fillCity: $el.data('city'),
          fillCounty: $el.data('county'),
          fillZip: $el.data('zip'),
          fillState: $el.data('state')
        },
        selector = $el.data('map');

    new PlaceAutocomplete(this, fillers, function (place) {
      setMap({
        selector: selector,
        name: place.name,
        lat: place.geometry.location.lat(),
        lng: place.geometry.location.lng()
      });
      $('#results').html('');
    });

  });

  $('#grade_level').on('change', function () {
    $('#results').html('');
    if (marker) {
      marker.setMap(null);
      map.setCenter(current_location.position);
      map.setZoom(12);
    }
    if (current_location) {
      $('#resolve_feeder_pattern').trigger('click');
    }
  });

  $('#resolve_feeder_pattern').on('click', function () {
    $.ajax({
      url: '/lookup',
      data: {
        grade_level: $('#grade_level').val(),
        lat: $('#geocode-lat').val(),
        lon: $('#geocode-lng').val()
      },
      dataType: 'json',
    })
      .done(function (data) {
        if (data) {
          if (marker) {
            marker.setMap(null);
          }
          if (data.geometry.coordinates) {
            marker = addMarker({
                lng: data.geometry.coordinates[0],
                lat: data.geometry.coordinates[1]
              },
              data.properties.school.name
            );
            zoomToFit([current_location, marker]);
          }
          $('#results').html('').append(
            `<div><small>School:</small><strong>${data.properties.school.name}</strong></div>`,
            `<div><small>District:</small><strong>${data.properties.district.name}</strong></div>`
          );
        } else {
          // This is an edge case trap
          $('#results').html('<em style="color:#ff6347">No results found.</em>');
          if (marker) {
            marker.setMap(null);
          }
        }
      })
      .fail(function (error) {
        if (marker) {
          marker.setMap(null);
          map.setCenter(current_location.position);
          map.setZoom(12);
        }
        if (error.status == 404) {
          $('#results').html('<em>No schools located for given information.</em>');
        } else {
          $('#results').html('<em style="color:#a22;">An error communicating with the server occurred.</em>');
        }
      });
  });
});
