require 'net/http'
require 'json'

placeholder = '/nyancat.gif'
subreddits = {
  'pug_gif' => '/r/Puggifs/hot.json?limit=100'
}

SCHEDULER.every '20s', first_in: 0 do |job|
  subreddits.each do |_, subreddit|
    http = Net::HTTP.new('www.reddit.com')
    response = http.request(Net::HTTP::Get.new(subreddit))
    json = JSON.parse(response.body)

    if json['data']['children'].none?
      send_event('reddit', image: "background-image:url(#{placeholder})")
    else
      urls = json['data']['children'].map{|child| child['data']['url'] }

      # Ensure we're linking directly to an image, not a gallery etc.
      valid_urls = urls.select{|url| url.downcase.end_with?('png', 'gif', 'jpg', 'jpeg')}
      send_event('reddit', image: "background-image:url(#{valid_urls.sample(1).first})")
    end
  end
end
