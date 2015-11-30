class Dashing.Newrelic extends Dashing.Widget
  onData: (data) ->
    if data?.count > 0
      $(@get('node')).attr 'style', "background-color:#EC663C;"
    else
      $(@get('node')).attr 'style', "background-color:#96bf48;"
