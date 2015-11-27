require 'faraday'
require 'faraday_middleware'
require 'time'

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
        text: truncated_text(pin['message']['text']),
        ts: Time.at(pin['message']['ts'].to_f).to_date.to_s,
      }
    end
  end

  def self.first
    all.first
  end

  def self.last(n)
    all[0...n] || first
  end

  private

  def self.truncated_text(text, length = 90)
    if text.length > length
      "#{text[0...length]}..."
    else
      text
    end
  end
end

SCHEDULER.every '1m', first_in: 0 do |job|
  if (pins = Pin.last(2))
    send_event('pins', { pins: pins })
  else
    send_event('pins', {
      avatar: "https://lh3.googleusercontent.com/-b7qeL2Ie7qw/VjJ6MUU-hOI/AAAAAAAAAAA/c2O4wAKDvM0/w192-h192-n/event_theme.jpg",
      text: "so sweet!"
    })
  end
end
