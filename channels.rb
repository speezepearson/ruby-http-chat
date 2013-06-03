class Channel
  # Represents a chat group, with a name and a history of posts.
  attr_reader :name
  def initialize(name, post_dataset)
    # "name" is the channel name.
    # "post_dataset" is a Sequel::Dataset containing the information
    #   for every post ever made in the channel.
    @name = name
    @dataset = post_dataset
  end

  def posts(range)
    # Returns an array containing all the posts whose post_id is in the
    #  given range.
    first = range.begin
    if range.end == -1
      last = @dataset.count-1
    elsif range.exclude_end?
      last = range.end - 1
    else
      last = range.end
    end
    hashes = @dataset.filter("#{first} <= post_id AND post_id<= #{last}")
    return hashes.map {|h| Post.new(self, h[:post_id], h[:speaker],
                                    h[:content])}
  end

  def new_post(speaker, content)
    # Appends a new post to the channel's post dataset.
    post_id = @dataset.count
    @dataset.insert(:post_id => post_id, :speaker => speaker,
                    :content => content)
  end
end

class ChannelDB
  # Represents a database that contains information about several channels.
  # Allows retrieval of channels based on their names.
  # A table may be created/modified by this class iff its name begins with
  #  "channel_".
  # 
  # Under the hood, may be subject to change:
  # Each Channel is assigned a table to hold all its posts, and one master
  #  table (named channel_tablenames) is used to map each Channel's
  #  (unique) name to the name of its table.

  def initialize database
    @database = database
    # Prepare the channel=>tablename lookup table.
    database.create_table? :channel_tablenames do
      primary_key String :chname
      String :tablename
    end
  end

  def [] chname
    # Returns the Channel of the given name (or nil if none such exists).
    return nil if !self.include? chname
    tablename = self.tablename(chname)
    return Channel.new(chname, @database.from(tablename))
  end

  def include? chname
    # Returns whether a Channel of the given name exists.
    return !@database[:channel_tablenames].where(:chname => chname).empty?
  end

  def create_channel chname
    # Creates a table for a new channel and adds the entry to the master
    #  table.
    tablename = self.new_tablename()
    @database.transaction do
      @database.create_table tablename do
        primary_key Integer :post_id
        String :speaker
        String :content
      end
      @database[:channel_tablenames].insert(:chname => chname,
                                            :tablename => tablename)
    end
  end

  def list_names
    # Returns an array of all the names of existing channels.
    hashes = @database[:channel_tablenames].select(:chname)
    return hashes.map {|h| h[:chname]}
  end

  def tablename chname
    # Returns the tablename corresponding to the given channelname,
    #  or nil if no such channel exists.
    hash = @database[:channel_tablenames].where(:chname => chname).first
    return nil if hash.nil?
    return hash[:tablename]
  end

  def new_tablename
    # Returns a tablename starting with "channel_" that does not exist.
    channel_number = @database[:channel_tablenames].count
    tablename = "channel_number_#{channel_number}"
  end
end



class Post
  # Represents a post in some channel, with an ID and the username of
  #  the speaker and the content of the post.
  attr_reader :channel, :post_id, :speaker, :content
  def initialize(channel, post_id, speaker, content)
    @channel = channel
    @post_id = post_id
    @speaker = speaker
    @content = content
  end

  def to_s
    return "#{self.speaker} (#{self.post_id}): #{self.content}"
  end
end
