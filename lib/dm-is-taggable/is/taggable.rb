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
        
        class_eval <<-RUBY
          remix n, :taggings

          enhance :taggings do
            property :#{self.storage_name.singular}_id, Integer, :nullable => false, :key => true
            belongs_to :tag
          end
          
          has n, :tags, :through => :post_tags
        RUBY
      end

      module ClassMethods
        def taggable?
          true
        end
      end # ClassMethods

      module InstanceMethods
        def tag(with_tag)
          p = PostTag.new(:tag => with_tag)
          self.post_tags << p
          p.save unless self.new_record?
        end
      end # InstanceMethods

    end # Taggable
  end # Is
end # DataMapper
