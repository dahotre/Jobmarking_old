$('.short_desc').show();
$('.full_desc').css('display', 'none');

$('.show_full_desc').click(function() {
  $(this).parent().parent().parent().find('.short_desc').hide();
  $(this).parent().parent().parent().find('.full_desc').show();
});

$('.show_short_desc').click(function() {
  $(this).parent().parent().parent().find('.short_desc').show();
  $(this).parent().parent().parent().find('.full_desc').hide();
});

$('.job h4').click(function() {
  $(this).parent().find('.short_desc').hide();
  $(this).parent().find('.full_desc').show();
});

$(".edit_job input[type='submit']").css('display', 'none');
$(".edit_job input, .edit_job textarea").focus(function() {
  $(".edit_job input[type='submit']").show();
});

$('#edit_refresh_btn').click(function() {
  $('.refresh_diff').hide('slow');
  $('#edit_refresh_directions').show('fast');
  var newDesc = $('#hidden_new_desc').text();
  $('#job_description').text(newDesc);
  $('#job_description').css('box-shadow', '0px 1px 1px rgba(0, 0, 0, 0.075) inset, 0px 0px 8px rgba(82, 236, 168, 0.6)');
  $('#job_description').css('outline', '0px none');
  $('#job_description').css('border-color', 'rgba(82, 236, 168, 0.8)');

});

$(window).scroll(function() {
  url = $('.pagination .next_page').attr('href');
  if(url && $(window).scrollTop() > $(document).height() - $(window).height() - 50) {
    $('.pagination').text('Fetching older jobs...');
    $.getScript(url);
  }
});