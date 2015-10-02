require 'faraday'
require 'faraday_middleware'
require 'byebug'


connection = Faraday.new('http://www.railslove.com') do |conn|
  conn.response :json
  conn.request :json
  conn.adapter :excon
end

SCHEDULER.every '500s' do |job|
  response = connection.get("/api/people").body
  response = response.map do |obj|
    obj.merge!({
      gravatar: "http://www.gravatar.com/avatar/" + Digest::MD5.new.hexdigest(obj['email'].downcase),
      url: "https://www.railslove.com/#{obj['slug']}"
    })
  end
  send_event('people', { people: response })
end
