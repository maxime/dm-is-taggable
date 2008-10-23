module Tagging
  include DataMapper::Resource
  
  property :id, Serial
  property :tag_id, Integer, :nullable => false
  
  is :remixable, :suffix => "tag"
end