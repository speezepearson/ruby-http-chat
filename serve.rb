require "sinatra"
require File.join(File.dirname(__FILE__), "server.rb")
require File.join(File.dirname(__FILE__), "page_templates.rb")

# Initialize the server. Soon, it should probably look like
#  server = Server.new(database)
server = Server.new

# Respond to requests for...

# ...the main page:
get "/" do
  return make_page(:index, nil)
end

# ...a list of all users:
get "/users" do
  return make_page(:user_list, server.list_users.join("<br />"))
end
# ...an attempted username registration:
post "/users" do
  return "no username given" if params[:uname].nil? or params[:uname].empty?
  return "username taken" if server.uname_taken? params[:uname]
  server.create_user(params[:uname], params[:password])
  return "registration successful"
end

# ...a list of all channels:
get "/channels" do
  return make_page(:channel_list, server.list_channels.join("<br />"))
end
# ...a channel creation:
post "/channels" do
  return "no channel name given" if params[:chname].nil? or params[:chname].empty?
  return "channel name taken" if server.chname_taken? params[:chname]
  server.create_channel params[:chname]
  return "channel created"
end

# ...a list of posts:
get "/posts" do
  return "no channel given" if params[:chname].nil? or params[:chname].empty?
  start, stop = 0, -1
  begin
    start = Integer(params[:start]) if not (params[:start].nil? or params[:start].empty?)
    stop = Integer(params[:stop]) if not (params[:stop].nil? or params[:stop].empty?)
  rescue ArgumentError
    return "bad start/stop value"
  end

  return "no such channel" if not server.chname_taken? params[:chname]

  posts = server.get_posts(params[:chname], start, stop)
  return make_page(:post_list, posts.join("<br />"))
end

# ...making new posts:
post "/posts" do
  return "no username given" if params[:uname].nil? or params[:uname].empty?
  return "no channelname given" if params[:chname].nil? or params[:chname].empty?
  return "no text given" if params[:text].nil? or params[:text].empty?
  return "no such channel" if not server.chname_taken? params[:chname]
  uname = params[:uname]
  password = params[:password]
  return "invalid user info" if not server.password_correct?(uname, password)
  server.new_post(params[:chname], uname, params[:text])
  return "post successful"
end
