class User
  attr_reader :name, :password
  def initialize(name, password=nil)
    @name = name
    @password = password
  end
end

class UserDB
  def initialize(database)
    database.create_table? :users do
      primary_key String :name
      String :password
    end
    @dataset = database[:users]
  end

  def [] name
    return nil if !self.include? name
    hash = @dataset.where(:name => name).first
    return User.new(hash[:name], hash[:password])
  end

  def include? name
    return !@dataset.where(:name => name).empty?
  end

  def create_user(name, password=nil)
    @dataset.insert(:name => name, :password => password)
  end

  def list_names
    hashes = @dataset.select(:name)
    return hashes.map {|h| h[:name]}
  end
end