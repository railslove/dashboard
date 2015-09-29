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

current_valuation = 0

SCHEDULER.every '1h', first_in: 0 do |job|
  last_valuation = current_valuation

  response = connection.get("/api/invoices?filter[status]=overdue,open&fields[]=net_total").body

  if invoices = response["invoices"]
    current_valuation = invoices.reduce(0) {|a,i| a += i["invoice"]["net_total"] }

    send_event('salesking', { current: current_valuation })
  else
    send_event('salesking', { current: 0 })
  end
end
