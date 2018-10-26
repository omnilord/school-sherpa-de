$(function () {
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
      simpleMap({
        selector: selector,
        name: place.name,
        lat: place.geometry.location.lat(),
        lng: place.geometry.location.lng()
      });
    });
  });
});
