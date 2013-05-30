require "sinatra"
require "~/chat/server.rb"

server = Server.new

PAGE_TEMPLATES = {:index => IO.read("index.html.erb"),
                  :user_list => IO.read("user_list.html.erb"),
                  :channel_list => IO.read("channel_list.html.erb"),
                  :post_list => IO.read("post_list.html.erb")}
def make_page(symbol, content)
  return PAGE_TEMPLATES[symbol].sub("<% CONTENT %>", content.to_s)
end

get "/" do
  return make_page(:index, nil)
end

get "/users" do
  return make_page(:user_list, server.list_users.join("<br />"))
end
post "/users" do
  return "no username given" if params[:uname].nil? or params[:uname].empty?
  return "username taken" if server.uname_taken? params[:uname]
  server.create_user(params[:uname], params[:password])
  return "registration successful"
end

get "/channels" do
  return make_page(:channel_list, server.list_channels.join("<br />"))
end
post "/channels" do
  return "no channel name given" if params[:chname].nil? or params[:chname].empty?
  return "channel name taken" if server.chname_taken? params[:chname]
  server.create_channel params[:chname]
  return "channel created"
end

get "/posts" do
  return "no channel given" if params[:chname].nil? or params[:chname].empty?
  start, stop = 0, -1
  begin
    start = Integer(params[:start]) if not (params[:start].nil? or params[:start].empty?)
    stop = Integer(params[:stop]) if not (params[:stop].nil? or params[:stop].empty?)
  rescue ArgumentError
    return "bad start/stop value"
  end

  channel = server.channels[params[:chname]]
  return "no such channel" if channel.nil?

  return make_page(:post_list, channel.posts[start..stop].join("<br />"))
end

post "/posts" do
  return "no username given" if params[:uname].nil? or params[:uname].empty?
  return "no channelname given" if params[:chname].nil? or params[:chname].empty?
  return "no text given" if params[:text].nil? or params[:text].empty?
  uname = params[:uname]
  password = params[:password]
  return "invalid user info" if not server.password_correct?(uname, password)
  channel = server.channels[params[:chname]]
  text = params[:text]
  return "no such channel" if channel.nil?
  channel.add_message(uname, text)
  return "post successful"
end
