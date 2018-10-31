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
              $('<strong></strong').text(data.properties.school.name)
            ),
            $('<div><small>District:</small></div>').append(
              $('<strong></strong>').text(data.properties.district.name)
            ),
          );
        } else {
          $('#results').html('<em>No schools located for given information.</em>');
        }
      })
      .fail(function (error) {
        $('#results').html('<em style="color:#a22;">An error communicating with the server occurred.</em>');
      });
  });
});
