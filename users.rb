require "digest"

SHA256 = Digest::SHA256.new

class User
  # Represents a user, with a username and (optionally) a (hash of a) password.
  attr_reader :name, :password_sha256
  def initialize(name, password_sha256=nil)
    @name = name
    @password_sha256 = password_sha256
  end

  def password_correct? password
    password_sha256 = SHA256.hexdigest(password)
    return password_sha256 == self.password_sha256
  end
end

class UserDB
  # Represents a database that contains information about several users.
  # Allows retrieval of users based on their names.
  # Uses the "users" table of the given database.
  def initialize(database)
    database.create_table? :users do
      primary_key String :name
      String :password_sha256
    end
    @dataset = database[:users]
  end

  def [] name
    # Return the User with the given name, or nil if none such exists.
    return nil if !self.include? name
    hash = @dataset.where(:name => name).first
    return User.new(hash[:name], hash[:password_sha256])
  end

  def include? name
    # Returns whether a user with the given name exists.
    return !@dataset.where(:name => name).empty?
  end

  def create_user(name, password=nil)
    # Inserts the information for a new user into the database.
    password_sha256 = SHA256.hexdigest(password)
    @dataset.insert(:name => name, :password_sha256 => password_sha256)
  end

  def list_names
    # Returns an array of the names of all existing users.
    hashes = @dataset.select(:name)
    return hashes.map {|h| h[:name]}
  end
end