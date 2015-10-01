require 'faraday'
require 'faraday_middleware'

# Salesking API key
key = ENV["SALESKING"]

connection = Faraday.new('https://railslove.salesking.eu', ssl: {version: :TLSv1}) do |conn|
  conn.headers["Authorization"] = "Bearer #{key}" # valid feb 5
  conn.response :json
  conn.request  :json
  conn.adapter :excon
end

SCHEDULER.every '1h', first_in: 0 do |job|
  response = connection.get("/api/invoices?filter[status]=overdue,open&fields[]=net_total&fields[]=created_at").body

  if invoices = response["invoices"]

    sum = invoices.select{|i|
     Time.parse(i["invoice"]["created_at"]) > Time.parse("2015-05-01")
    }.reduce(0) {|a,i| a += i["invoice"]["net_total"] }

    send_event('salesking', { current: sum })
  else
    send_event('salesking', { current: 0 })
  end
end
