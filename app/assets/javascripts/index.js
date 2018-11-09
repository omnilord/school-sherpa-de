$(function () {
  var tabs = $(document.getElementsByName('tab_toggle')).on('change', function () {
    var target_id = $(this).attr('id');
    tabs.each(function () {
      var id = $(this).attr('id');

      $(`label[for="${id}"]`).toggleClass('checked', target_id === id);
    });
  });
});
