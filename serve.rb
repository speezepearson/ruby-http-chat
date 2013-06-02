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
  return index_page
end

# ...an attempted username registration:
post "/register" do
  uname, password = params[:uname], params[:password]
  return status_page("no username given") if uname.nil? or uname.empty?
  return status_page("user #{uname} exists") if server.user_exists? uname
  server.create_user(uname, password)
  session[:uname], session[:password] = uname, password
  return status_page("registration successful")
end
# ...creating a channel:
post "/channels" do
  chname = params[:chname]
  return status_page("no channel name given") if chname.nil? or chname.empty?
  return status_page("channel #{chname} exists") if server.channel_exists? chname
  server.create_channel chname
  return status_page("created channel #{chname}")
end
# ...making a post:
post "/posts" do
  chname, content = session[:chname], params[:content]
  return status_page("no channel joined") if chname.nil? or chname.empty?
  return status_page("channel #{chname} does not exist") if !server.channel_exists? chname
  return status_page("no content given") if content.nil? or content.empty?
  uname = session[:uname]
  password = session[:password]
  return status_page("not logged in") if uname.nil?
  return status_page("invalid user info") if !server.password_correct?(uname, password)

  server.new_post(chname, uname, params[:content])
  return status_page("post successful")
end

# ...logging in:
get "/login" do
  uname, password = params[:uname], params[:password]
  return status_page("no username given") if uname.nil? or uname.empty?
  return status_page("already logged in as #{uname}") if session[:uname] == uname
  return status_page("invalid user info") if !server.password_correct?(uname, password)
  session[:uname] = uname
  session[:password] = password
  return status_page("logged in as #{uname}")
end
# ...joining a channel:
get "/join_channel" do
  chname = params[:chname]
  return status_page("no channel name given") if chname.nil? or chname.empty?
  return status_page("no such channel") if !server.channel_exists? chname
  session[:chname] = chname
  return status_page("joined channel #{chname}")
end

# ...a list of channels:
get "/channels" do
  return list_page("All channels:", server.list_chnames)
end
# ...a list of users:
get "/users" do
  return list_page("All users:", server.list_unames)
end
# ...a list of posts:
get "/posts" do
  chname = session[:chname]
  return status_page("no channel") if chname.nil? or chname.empty?
  return status_page("no such channel") if !server.channel_exists? chname
  start, stop = 0, -1
  begin
    start = Integer(params[:start]) if !(params[:start].nil? or params[:start].empty?)
    stop = Integer(params[:stop]) if !(params[:stop].nil? or params[:stop].empty?)
  rescue ArgumentError
    return status_page("bad start/stop value")
  end

  posts = server.get_posts(chname, start, stop)
  return posts_page(chname, posts)
end

