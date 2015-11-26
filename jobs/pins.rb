require 'faraday'
require 'faraday_middleware'

module Connection
  def key
    @key = ENV['SLACK'].split('/')[0]
  end

  def channel
    @channel = ENV['SLACK'].split('/')[1]
  end

  def connection
    @connection ||= Faraday.new('https://slack.com', ssl: {version: :TLSv1}) do |conn|
      conn.request :url_encoded
      conn.response :json
      conn.request :json
      conn.adapter :excon
    end
  end
end

class Member
  extend Connection

  def self.all
    @members ||= connection.get("/api/users.list?token=#{key}").body['members'].map do |member|
      {id: member['id'], name: member['name'], avatar: member['profile']['image_192']}
    end
  end

  def self.find(id)
    all.detect{|m| m[:id] == id }
  end
end

class Pin
  extend Connection

  def self.all
    connection.get("/api/pins.list?token=#{key}&channel=#{channel}").body['items'].map do |pin|
      member = Member.find(pin['message']['user'])
      {
        avatar: member[:avatar],
        user: member[:name],
        text: pin['message']['text'],
        ts: pin['message']['ts']
      }
    end
  end

  def self.first
    all.first
  end
end

SCHEDULER.every '1m', first_in: 0 do |job|
  puts "asdsad"

  if (pin = Pin.first)
    send_event('pins', pin)
  else
    send_event('pins', {
      avatar: "https://lh3.googleusercontent.com/-b7qeL2Ie7qw/VjJ6MUU-hOI/AAAAAAAAAAA/c2O4wAKDvM0/w192-h192-n/event_theme.jpg",
      text: "so sweet!"
    })
  end
end
