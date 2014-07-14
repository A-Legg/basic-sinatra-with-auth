require "sinatra"
require "rack-flash"
<<<<<<< HEAD

require "./lib/user_database"
=======
require "active_record"
require "./lib/database_connection"

>>>>>>> upstream/master

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
<<<<<<< HEAD
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
=======
    @database_connection = DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    if session[:id]
      user_name
      if params[:sort_ascending]
        list = registered_users_list.sort
      elsif params[:sort_descending]
        list = registered_users_list.sort.reverse
      end
      erb :logged_in, :locals=>{:user_name=>user_name, :list=> list}
    else
      erb :homepage
    end

  end

  get "/register" do
    erb :register
  end

  get "/login" do
    erb :login
  end

  get "/logout" do
    session.clear
    redirect '/'
  end

  post "/register" do
    check_reg(params[:username], params[:password])
  end

  post "/sessions" do
      check_login(params[:username], params[:password])
      session[:id] = current_user['id'].to_i if current_user
      redirect '/'
>>>>>>> upstream/master
  end

  private

<<<<<<< HEAD
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
=======
  def current_user
    (@database_connection.sql("SELECT * from users where username = '#{params[:username]}';")).first
  end

  def user_name
    (@database_connection.sql("SELECT * from users where id = '#{session[:id]}';")).first['username']
  end

  def check_reg(username, password)
    if username == "" && password == ""
      flash[:notice] = "Please enter a username. Please enter a password"
      redirect back
    elsif username == ""
      flash[:notice] = "Please enter a username"
      redirect back
    elsif (@database_connection.sql("SELECT username from users")).select {|user_hash| user_hash['username'] == username } != []
      flash[:notice] = "That username is already taken"
      redirect back
    elsif password == ""
      flash[:notice] = "Please enter a password"
      redirect back
    else @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{ params[:username] }', '#{ params[:password] }')") == []
      flash[:notice] = "Thank you for registering"
      redirect  "/"
    end
  end

  def check_login(username, password)
    if (@database_connection.sql("SELECT username from users")).select {|user_hash| user_hash['username'] == username } == []
    flash[:notice] = "Username doesn't exist"
    redirect back
    elsif username == "" && password == ""
      flash[:notice] = "Please enter a username. Please enter a password"
      redirect back
    elsif username == ""
      flash[:notice] = "Please enter a username"
      redirect back
    elsif password == ""
      flash[:notice] = "Please enter a password"
      redirect back
    elsif (@database_connection.sql("SELECT username, password from users")).select { |user_hash|
      user_hash['username'] == username && user_hash['password'] != password } != []
      flash[:notice] = "Password is incorrect"
      redirect back
    else (@database_connection.sql("SELECT username, password from users")).select { |user_hash|
      user_hash['username'] == username && user_hash['password'] == password } != []
    end
  end

  def registered_users_list
    (@database_connection.sql("SELECT username from users")).map do |user_hash|
      user_hash['username']
    end
  end

end






>>>>>>> upstream/master
