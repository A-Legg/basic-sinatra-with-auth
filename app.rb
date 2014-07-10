require "sinatra"
require "rack-flash"

require "./lib/user_database"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @user_database = UserDatabase.new
  end

  get "/" do
    if current_user
      erb :signed_in, locals: {username: current_user[:username]}
    else
      erb :signed_out
    end
  end

  get "/registrations/new" do
    erb :"registrations/new"
  end

  post "/registrations" do
    @user_database.insert(username: params[:username], password: params[:password])
    flash[:notice] = "Thank you for registering"
    redirect "/"
  end

  post "/sessions" do
    user = find_user(params)
    session[:user_id] = user[:id] if user
    redirect "/"
  end

  get "/sign_out" do
    session.delete(:user_id)
    redirect "/"
  end

  private

  def find_user(params)
    @user_database.all.select { |user|
      user[:username] == params[:username] && user[:password] == params[:password]
    }.first
  end

  def current_user
    if session[:user_id]
      @user_database.find(session[:user_id])
    end
  end
end