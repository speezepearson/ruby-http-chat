require File.join(File.dirname(__FILE__), "channel.rb")

class Server
  # Allows access to all the serverside state: creating/listing
  #  users/channels, posting/listing messages, checking login
  #  credentials, etc.
  def initialize
    @passwords = {}
    @channels = {}
  end
  
  def password_correct?(uname, password)
    return @passwords[uname] == password
  end
  def uname_taken? uname
    return @passwords.include? uname
  end
  def create_user(uname, password)
    @passwords[uname] = password
  end
  def list_users
    return @passwords.keys
  end

  def chname_taken? chname
    return @channels.include? chname
  end
  def create_channel chname
    @channels[chname] = Channel.new(chname)
  end
  def list_channels
    return @channels.keys
  end
  def new_post(chname, uname, text)
    @channels[chname].add_post(uname, text)
  end
  def get_posts(chname, start, stop)
    return @channels[chname].posts[start..stop]
  end
end
