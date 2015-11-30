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
    down = servers.select{|server| (server["health_status"] != "green" && server["health_status"] != "orange") }

    send_event('servers', { count: down.size, names: down.map{|s| s["name"]}.join(", ") })
  else
    send_event('servers', { count: 0, names: "n/a" })
  end

end
