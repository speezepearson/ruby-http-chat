require "~/chat/channel.rb"

class Server
  attr_accessor, :passwords, :channels
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
end
