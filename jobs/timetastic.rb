require "open-uri"
require "icalendar"

key = ENV["TIMETASTIC"]

SCHEDULER.every '180m', first_in: 0 do
  cal_file = Kernel.open("https://app.timetastic.co.uk/Feeds/OrganisationCalendar/#{key}")

  cals = Icalendar.parse(cal_file)
  cal  = cals.first

  events = cal.events.select{|e| e.dtstart < Time.now.beginning_of_day && e.dtend > Time.now.end_of_day }.map{|e| { value: e.summary.force_encoding("UTF-8").split(" ",2)[0] } }

  send_event('leaves', { items: events })

  cal_file.close
end
