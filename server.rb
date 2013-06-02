require File.join(File.dirname(__FILE__), "channel.rb")

class Server
  # Allows access to all the serverside state: creating/listing
  #  users/channels, posting/listing messages, checking login
  #  credentials, etc.
  def initialize(database)
    @user_db = UserDB.new(database)
    @channel_db = ChannelDB.new(database)
  end
  
  def password_correct?(uname, password)
    return false if !self.user_exists? uname
    user = @user_db[uname]
    return password == @user_db[uname].password
  end
  def user_exists? uname
    return ! @user_db[uname].nil?
  end
  def create_user(uname, password)
    @user_db.create_user(uname, password)
  end
  def list_unames
    return @user_db.list_names
  end

  def channel_exists? chname
    return ! @channel_db[chname].nil?
  end
  def create_channel chname
    @channel_db.create_channel(chname)
  end
  def list_chnames
    return @channel_db.list_names
  end
  def new_post(chname, uname, content)
    @channel_db[chname].new_post(uname, content)
  end
  def get_posts(chname, start, stop)
    return @channel_db[chname].posts(start..stop)
  end
end
