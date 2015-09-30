# curl -v -H "X-FreckleToken:scbp72wdc528hm8n52fowkma321tn58-jc1l2dkil0pnb75xjni48ad2wwsgr1d" https://api.letsfreckle.com/v2/timers

require 'faraday'
require 'faraday_middleware'

# Newrelic API key
key = ENV["FRECKLE"]

connection = Faraday.new('https://api.letsfreckle.com', ssl: {version: :TLSv1}) do |conn|
  conn.request :url_encoded
  conn.headers["X-FreckleToken"]=key
  conn.headers["User-Agent"]= "Railslove Kiosk"
  conn.response :json
  conn.request  :json
  conn.adapter :excon
end


SCHEDULER.every '15m', first_in: 0 do |job|
  response = connection.get("/v2/entries", {billable: true, from: Date.today, to: Date.tomorrow}).body

  count = response.reduce(0) {|a,e| a += e["minutes"] } / 60.0

  send_event('freckle', { value: count })
end
