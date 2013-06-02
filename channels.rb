class Channel
  attr_reader :name
  def initialize(name, post_dataset)
    @name = name
    @dataset = post_dataset
  end

  def posts(range)
    first = range.begin
    if range.end == -1
      last = @dataset.count-1
    elsif range.exclude_end?
      last = range.end - 1
    else
      last = range.end
    end
    hashes = @dataset.filter("#{first} <= post_id AND post_id<= #{last}")
    return hashes.map {|h| Post.new(h[:speaker], h[:content])}
  end

  def new_post(speaker, content)
    post_id = @dataset.count
    @dataset.insert(:post_id => post_id, :speaker => speaker,
                    :content => content)
  end
end

class ChannelDB
  def initialize database
    @database = database
    database.create_table? :channel_tablenames do
      primary_key String :chname
      String :tablename
    end
  end

  def [] chname
    return nil if !self.include? chname
    tablename = self.tablename(chname)
    return Channel.new(chname, @database.from(tablename))
  end

  def include? chname
    return !@database[:channel_tablenames].where(:chname => chname).empty?
  end

  def tablename chname
    hash = @database[:channel_tablenames].where(:chname => chname).first
    return nil if hash.nil?
    return hash[:tablename]
  end

  def create_channel chname
    channel_number = @database[:channel_tablenames].count
    tablename = "channel_number_#{channel_number}"
    @database.create_table tablename do
      primary_key Integer :post_id
      String :speaker
      String :content
    end
    @database[:channel_tablenames].insert(:chname => chname,
                                          :tablename => tablename)
  end

  def list_names
    hashes = @database[:channel_tablenames].select(:chname)
    return hashes.map {|h| h[:chname]}
  end
end



class Post
  attr_reader :speaker, :content
  def initialize(speaker, content)
    @speaker = speaker
    @content = content
  end

  def to_s
    return "#{self.speaker}: #{self.content}"
  end
end
