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
        options[:by] ||= []
        
        taggers_associations = ""
        options[:by].each do |tagger_class|
          taggers_associations << "belongs_to :#{Extlib::Inflection.underscore(tagger_class.to_s)}\n"
        end
        
        class_eval <<-RUBY
          remix n, :taggings

          enhance :taggings do
            belongs_to :tag
          
            #{taggers_associations}
          end
          
          has n, :tags, :through => :#{Extlib::Inflection.underscore(self.to_s)}_tags
        RUBY
        
        Tag.class_eval <<-RUBY
          has n, :#{Extlib::Inflection.underscore(self.to_s)}_tags
          has n, :#{self.storage_name}, :through => :#{Extlib::Inflection.underscore(self.to_s)}_tags
        RUBY
        
        options[:by].each do |tagger_class|
          tagger_class.class_eval <<-RUBY
            is :tagger, :for => [#{self}]
          RUBY
        end
      end

      module ClassMethods
        def taggable?
          true
        end
      end # ClassMethods

      module InstanceMethods
        def tag(tag_name)
          p = Extlib::Inflection::constantize("#{self.class.to_s}Tag").new(:tag => tag_name)
          self.send("#{Extlib::Inflection::underscore(self.class.to_s)}_tags") << p
          p.save unless self.new_record?
        end
        
        def untag(tag_name)
          p = self.send("#{Extlib::Inflection::underscore(self.class.to_s)}_tags").first(:tag_id => tag_name.id)
          p.destroy if p
        end
        
        def tags_list
          self.tags.collect {|t| t.name}.join(", ")
        end
        
        def tags_list=(list)
          self.send("#{Extlib::Inflection::underscore(self.class.to_s)}_tags").destroy!
          list = list.split(",").collect {|s| s.strip}
          list.each do |t|
            self.tag(Tag.build(t))
          end
        end
      end # InstanceMethods

    end # Taggable
  end # Is
end # DataMapper
