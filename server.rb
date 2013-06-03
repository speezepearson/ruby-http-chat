require File.join(File.dirname(__FILE__), "channels.rb")
require File.join(File.dirname(__FILE__), "users.rb")

class Server
  # Allows access to all the serverside state: creating/listing
  #  users/channels, posting/listing messages, checking login
  #  credentials, etc.
  def initialize(database)
    @user_db = UserDB.new(database)
    @channel_db = ChannelDB.new(database)
  end
  
  def password_correct?(uname, password)
    # If a user exists with name uname and password password, returns true.
    # Otherwise, returns False.
    return false if !self.user_exists? uname
    return @user_db[uname].password_correct? password
  end
  def user_exists? uname
    # Returns whether a user exists with the given name.
    return !@user_db[uname].nil?
  end
  def create_user(uname, password=nil)
    @user_db.create_user(uname, password)
  end
  def list_unames
    # Returns an array of all taken usernames.
    return @user_db.list_names
  end

  def channel_exists? chname
    # Returns whether a channel exists with the given name.
    return !@channel_db[chname].nil?
  end
  def create_channel chname
    @channel_db.create_channel(chname)
  end
  def list_chnames
    # Returns an array of all taken channelnames.
    return @channel_db.list_names
  end
  def new_post(chname, uname, content)
    # Adds a new post to the given channel.
    @channel_db[chname].new_post(uname, content)
  end
  def get_posts(chname, range)
    # Returns all posts from the given channel whose IDs are in the given range.
    return @channel_db[chname].posts(range)
  end
end
