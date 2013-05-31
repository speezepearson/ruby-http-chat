class Post
  # Represents a message from a user of the chat service.
  # Stores the speaker's name and the content of the message.
  attr_accessor :uname, :text
  def initialize(uname, text)
    @uname = uname
    @text = text
  end

  def to_s
    return "#{self.uname}: #{self.text}"
  end
end

class Channel
  # Represents a channel, with a name and sequence of posts.
  attr_accessor :name, :posts
  def initialize(name)
    @name = name
    @posts = []
  end

  def add_post(uname, text)
    @posts << Post.new(uname, text)
  end
end
