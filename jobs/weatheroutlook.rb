require "net/http"
require "json"

# WOEID for location:
# http://woeid.rosselliot.co.nz
woeid  = 20066504   # cologne 50678

# Units for temperature:
# f: Fahrenheit
# c: Celsius
format = "c"

query  = URI::encode "select * from weather.forecast WHERE woeid=#{woeid} and u='#{format}'&format=json"

SCHEDULER.every "15m", :first_in => 0 do |job|
  http     = Net::HTTP.new "query.yahooapis.com"
  request  = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results  = response["query"]["results"]["channel"]["item"]["forecast"]

  if results
    forecasts = []
    (0..1).each_with_index do |day, i|
      day = results[day]

      this_day = {
        high: day["high"],
        low:  day["low"],
        date: { 0 => 'Today', 1 => 'Tomorrow' }.fetch(i, ''),
        code: day["code"],
        text: day["text"],
        format: format
      }
      forecasts.push(this_day)
    end

    send_event "weatheroutlook", { forecasts: forecasts }
  end
end
