require "open-uri"
require "icalendar"

key = ENV["TIMETASTIC"]

SCHEDULER.every '180m', first_in: 0 do
  cal_file = Kernel.open("https://app.timetastic.co.uk/Feeds/OrganisationCalendar/#{key}")

  cals = Icalendar.parse(cal_file)
  cal  = cals.first

  events = cal.events.select{|e| (e.dtstart...e.dtend).cover? Icalendar::Values::Date.new(Date.today) }.map{|e| { value: e.summary.force_encoding("UTF-8").split(" ",2)[0] } }

  send_event('leaves', { items: events })

  cal_file.close
end
