class Dashing.People extends Dashing.Widget
  onData: (data) ->
    $('.in-the-office').removeClass('in-the-office')
    $.each data.onsite, (index, personName) ->
      $("##{personName}").addClass('in-the-office');
