class Post
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :description, Text
  
  is :taggable
end
