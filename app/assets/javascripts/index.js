$(function () {
  var tabs = $(document.getElementsByName('tab_toggle')).on('change', function () {
    var target_id = $(this).attr('id');
    tabs.each(function () {
      var id = $(this).attr('id');

      $(`label[for="${id}"]`).toggleClass('checked', target_id === id);
    });
  });

  $('select[data-require-place="true"]').on('change', function () {
    $(this).siblings('button[data-require-place="true"]').prop('disabled', false);
  });
});

function reset_selection_controls() {
  $('div.place-completed').removeClass('place-completed');
  $('input[type="radio"]').each(function () { this.checked = false; });
  $('label[role="tab"]').removeClass('checked');
  $('select[data-require-place="true"]').prop('selectedIndex', 0);
  $('select[data-require-place="true"] + button[data-require-place="true"]').prop('disabled', true);
}
