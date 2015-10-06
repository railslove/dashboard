require 'faraday'
require 'faraday_middleware'

# Newrelic API key
key = ENV["NEWRELIC"]

connection = Faraday.new('https://api.newrelic.com', ssl: {version: :TLSv1}) do |conn|
  conn.request :url_encoded
  conn.headers["X-Api-Key"]=key
  conn.response :json
  conn.request :json
  conn.adapter :excon
end

SCHEDULER.every '15s' do |job|

  response = connection.get("https://api.newrelic.com/v2/servers.json").body

  if servers = response["servers"]
    count = servers.count{|server| (server["health_status"] != "green" && server["health_status"] != "orange") }

    send_event('servers', { text: count })
  else
    send_event('servers', { text: "n/a" })
  end

end
