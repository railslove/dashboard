require 'faraday'
require 'faraday_middleware'
require 'json'
require 'net/http'

def subreddits
  [
    '/r/puppygifs/hot.json?limit=50',
    '/r/doggifs/hot.json?limit=50',
    '/r/Puggifs/hot.json?limit=50',
    '/r/catgifs/hot.json?limit=50',
    '/r/combinedgifs/hot.json?limit=50',
  ]
end

def connection 
  Faraday.new('http://www.reddit.com') do |conn|
    conn.response :json
    conn.request :json
    conn.adapter :excon
  end
end

def gif_url
  response = connection.get(subreddits.sample)
  next_gif_url = '/nyancat.gif'

  if response.success?
    urls = response.body['data']['children'].map do |child|
      child['data']['url'] if child['data']['url'].downcase.end_with?('gif')
    end.compact

    urls.shuffle.each do |url|
      if Net::HTTP.get_response(URI(url)).is_a?(Net::HTTPSuccess)
        next_gif_url = url 
        break
      end
    end
  end

  next_gif_url
end

SCHEDULER.every '10s', first_in: 0 do |job|
  send_event('reddit', image: "background-image:url(#{gif_url}); background-size: 100% 100%")
end
