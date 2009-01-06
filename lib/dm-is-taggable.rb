# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core', '=0.9.9'
require 'dm-core'

require 'dm-is-remixable'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'dm-is-taggable' / 'is' / 'taggable.rb'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-taggable' / 'is' / 'tag.rb'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-taggable' / 'is' / 'tagging.rb'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-taggable' / 'is' / 'tagger.rb'

# Include the plugin in Resource
module DataMapper
  module Resource
    module ClassMethods
      include DataMapper::Is::Taggable
      include DataMapper::Is::Tagger
    end # module ClassMethods
  end # module Resource
end # module DataMapper
