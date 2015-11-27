require 'dashing'

configure do
  set :auth_token, 'bok9dif3It'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

use Rack::Auth::Basic, "Dashing" do |username, password|
  username == ENV["USERNAME"].to_s
end
run Sinatra::Application
