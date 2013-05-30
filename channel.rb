class Post
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
  attr_accessor :name, :posts
  def initialize(name)
    @name = name
    @posts = []
  end

  def add_message(uname, text)
    @posts << Post.new(uname, text)
  end
end
