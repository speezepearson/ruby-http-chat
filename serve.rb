require "sinatra"
require "sequel"
require File.join(File.dirname(__FILE__), "server.rb")
require File.join(File.dirname(__FILE__), "page_templates.rb")

enable :sessions

# Initialize the server.
server = Server.new(Sequel.connect("sqlite://server.db"))

# Respond to requests for...

# ...the main page:
get "/" do
  return make_page(:index)
end

# ...an attempted username registration:
post "/register" do
  uname, password = params[:uname], params[:password]
  return make_page(:status, :content => "no username given") if uname.nil? or uname.empty?
  return make_page(:status, :content => "user #{uname} exists") if server.user_exists? uname
  server.create_user(uname, password)
  session[:uname], session[:password] = uname, password
  return make_page(:status, :content => "registration successful")
end
# ...creating a channel:
post "/channels" do
  chname = params[:chname]
  return make_page(:status, :content => "no channel name given") if chname.nil? or chname.empty?
  return make_page(:status, :content => "channel #{chname} exists") if server.channel_exists? chname
  server.create_channel chname
  return make_page(:status, :content => "created channel #{chname}")
end
# ...making a post:
post "/posts" do
  chname, content = session[:chname], params[:content]
  return make_page(:status, :content => "no channel joined") if chname.nil? or chname.empty?
  return make_page(:status, :content => "channel #{chname} does not exist") if !server.channel_exists? chname
  return make_page(:status, :content => "no content given") if content.nil? or content.empty?
  uname = session[:uname]
  password = session[:password]
  return make_page(:status, :content => "not logged in") if uname.nil?
  return make_page(:status, :content => "invalid user info") if !server.password_correct?(uname, password)

  server.new_post(chname, uname, params[:content])
  return make_page(:status, :content => "post successful")
end

# ...logging in:
get "/login" do
  uname, password = params[:uname], params[:password]
  return make_page(:status, :content => "no username given") if uname.nil? or uname.empty?
  return make_page(:status, :content => "already logged in as #{uname}") if session[:uname] == uname
  return make_page(:status, :content => "invalid user info") if !server.password_correct?(uname, password)
  session[:uname] = uname
  session[:password] = password
  return make_page(:status, :content => "logged in as #{uname}")
end
# ...joining a channel:
get "/join_channel" do
  chname = params[:chname]
  return make_page(:status, :content => "no channel name given") if chname.nil? or chname.empty?
  return make_page(:status, :content => "no such channel") if !server.channel_exists? chname
  session[:chname] = chname
  return make_page(:status, :content => "joined channel #{chname}")
end

# ...a list of channels:
get "/channels" do
  return make_page(:list, :title => "All channels:", :content => server.list_chnames)
end
# ...a list of users:
get "/users" do
  return make_page(:list, :title => "All users:", :content => server.list_unames)
end
# ...a list of posts:
get "/posts" do
  chname = session[:chname]
  return make_page(:status, :content => "no channel") if chname.nil? or chname.empty?
  return make_page(:status, :content => "no such channel") if !server.channel_exists? chname
  start, stop = 0, -1
  begin
    start = Integer(params[:start]) if !(params[:start].nil? or params[:start].empty?)
    stop = Integer(params[:stop]) if !(params[:stop].nil? or params[:stop].empty?)
  rescue ArgumentError
    return make_page(:status, :content => "bad start/stop value")
  end

  posts = server.get_posts(chname, start..stop)
  return make_page(:posts, :title => chname, :posts => posts)
end

