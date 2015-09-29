class Dashing.Hellotab extends Dashing.Widget

  hexToRgbA: (hex) =>
    h = hex.replace('#', '')
    h = h.match(new RegExp('(.{' + h.length / 3 + '})', 'g'))
    i = 0
    while i < h.length
      foo =if h[i].length == 1 then (h[i] + h[i]) else (h[i])
      h[i] = parseInt(foo, 16)
      i++

    ((1 << 24) + (h[0] << 16) + (h[1] << 8) + h[2]).toString(16).slice(1);

  onData: (data) ->
    if data.background_color
      color = if (parseInt(@hexToRgbA("#fff"), 16) > 0xffffff/2) then '#323232' else '#fff';
      $(@get('node')).attr 'style', "background-color:"+data.background_color+";"
      $(@get('node')).children().attr("style", "color:"+color+";")
