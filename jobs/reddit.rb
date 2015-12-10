require 'faraday'
require 'faraday_middleware'
require 'json'

subreddits = [
  '/r/puppygifs/hot.json?limit=50',
  '/r/doggifs/hot.json?limit=50',
  '/r/Puggifs/hot.json?limit=50',
]

connection = Faraday.new('http://www.reddit.com') do |conn|
  conn.response :json
  conn.request :json
  conn.adapter :excon
end

SCHEDULER.every '30s', first_in: 0 do |job|
  response = connection.get(subreddits.sample)

  gif = if response.success?
    urls = response.body['data']['children'].map do |child|
      child['data']['url'] if child['data']['url'].downcase.end_with?('gif')
    end.compact

    urls.shuffle!.sample
  else
    '/nyancat.gif'
  end

  send_event('reddit', image: "background-image:url(#{gif}); background-size: 100% 100%")
end
