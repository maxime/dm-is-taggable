module DataMapper
  module Is
    module Taggable

      ##
      # fired when your plugin gets included into Resource
      #
      def self.included(base)

      end

      ##
      # Methods that should be included in DataMapper::Model.
      # Normally this should just be your generator, so that the namespace
      # does not get cluttered. ClassMethods and InstanceMethods gets added
      # in the specific resources when you fire is :example
      ##

      def is_taggable(options={})

        # Add class-methods
        extend  DataMapper::Is::Taggable::ClassMethods
        # Add instance-methods
        include DataMapper::Is::Taggable::InstanceMethods
        
        # Make the magic happen
        
        class_eval <<-RUBY
          remix n, :taggings

          enhance :taggings do
            property :#{self.storage_name.singular}_id, Integer, :nullable => false, :key => true
            belongs_to :tag
          end
          
          has n, :tags, :through => :#{self.storage_name.singular}_tags
        RUBY
        
        Tag.class_eval <<-RUBY
          has n, :#{self.storage_name.singular}_tags
          has n, :#{self.storage_name}, :through => :#{self.storage_name.singular}_tags
        RUBY
      end

      module ClassMethods
        def taggable?
          true
        end
      end # ClassMethods

      module InstanceMethods
        def tag(tag_name)
          p = PostTag.new(:tag => tag_name)
          self.post_tags << p
          p.save unless self.new_record?
        end
        
        def untag(tag_name)
          p = self.post_tags.first(:tag_id => tag_name.id)
          p.destroy if p
        end
      end # InstanceMethods

    end # Taggable
  end # Is
end # DataMapper
