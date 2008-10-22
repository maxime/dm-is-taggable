module Tagging
  include DataMapper::Resource
  
  property :tag_id, Integer, :nullable => false, :key => true
  
  is :remixable, :suffix => "tag"
end