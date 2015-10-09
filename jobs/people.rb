require 'faraday'
require 'faraday_middleware'
require 'byebug'
require "open-uri"
require "icalendar"

key = ENV["TIMETASTIC"]

connection = Faraday.new('http://www.railslove.com') do |conn|
  conn.response :json
  conn.request :json
  conn.adapter :excon
end

SCHEDULER.every '180m', first_in: 0 do |job|
  cal_file = Kernel.open("https://app.timetastic.co.uk/Feeds/OrganisationCalendar/#{key}")
  cals = Icalendar.parse(cal_file)
  cal  = cals.first
  vacation_people_hash = cal.events.select{|e| (e.dtstart..e.dtend).cover? Icalendar::Values::Date.new(Date.today) }.map{|e| { value: e.summary.force_encoding("UTF-8").split(" ",2)[0] } }
  vacation_people = vacation_people_hash.map(&:values).flatten
  cal_file.close


  response = connection.get("/api/people").body
  response = response.map do |obj|
    obj.merge!({
      gravatar: "http://www.gravatar.com/avatar/" + Digest::MD5.new.hexdigest(obj['email'].downcase),
      url: "https://www.railslove.com/#{obj['slug']}",
      vacation: vacation_people.include?(obj['name'])
    })
  end
  send_event('people', { people: response })
end
