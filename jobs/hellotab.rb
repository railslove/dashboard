require 'faraday'
require 'faraday_middleware'

# Newrelic API key
key = ENV["HELLOTAB"]

connection = Faraday.new('https://hellotab.com', ssl: {version: :TLSv1}) do |conn|
  conn.request :url_encoded
  conn.response :json
  conn.request  :json
  conn.adapter :excon
end


SCHEDULER.every '5m', first_in: 0 do |job|

  response = connection.get("/api/v2/#{key}/messages").body

  if response["message"]
    send_event('hellotab', response["message"] )
  else
    send_event('hellotab', { body: "oh noez!" } )
  end
end
