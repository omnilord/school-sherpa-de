$(function () {
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
        // TODO: Show results as markers on map, zoom to fit both markers
          $('#results').html('').append(
            $('<div><small>School:</small></div>').append(
              $('<strong></strong').text(data.school)
            ),
            $('<div><small>District:</small></div>').append(
              $('<strong></strong>').text(data.district)
            ),
          );
        } else {
          $('#results').html('<em>No schools located for given information.</em>');
        }
      })
      .fail(function (a, b, c) {
        // TODO: alert the end user there was a failure
        console.log(a, b, c);
      });
  });
});
