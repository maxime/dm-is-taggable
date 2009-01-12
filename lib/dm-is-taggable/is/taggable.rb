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
            belongs_to :#{Extlib::Inflection.underscore(self.to_s)}
            #{taggers_associations}
          end
          
          has n, :tags, :through => :#{Extlib::Inflection.underscore(self.to_s)}_tags
        RUBY
        
        Tag.class_eval <<-RUBY
          has n, :#{Extlib::Inflection.underscore(self.to_s)}_tags
          has n, :#{Extlib::Inflection.underscore(self.to_s).pluralize}, :through => :#{Extlib::Inflection.underscore(self.to_s)}_tags
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
        
        def tagged_with(tags)
          # tags can be an object or an array
          tags = [tags] unless tags.class == Array
          
          # Transform Strings to Tags if necessary
          tags.collect!{|t| t.class == Tag ? t : Tag.build(t)}
          
          # Query the objects tagged with those tags
          taggings = Extlib::Inflection::constantize("#{self.to_s}Tag").all(:tag_id.in => tags.collect{|t| t.id})
          taggings.collect{|tagging| tagging.send(Extlib::Inflection::underscore(self.to_s)) }
        end
      end # ClassMethods

      module InstanceMethods
        def tag(tags)
          tags = [tags] unless tags.class == Array
          
          tags.each do |tag_name|
            tag_name = Tag.build(tag_name) if tag_name.class == String
            next if self.send("#{Extlib::Inflection::underscore(self.class.to_s)}_tags").first(:tag_id => tag_name.id, "#{Extlib::Inflection::underscore(self.class.to_s)}_id".intern => self.id)
            
            p = Extlib::Inflection::constantize("#{self.class.to_s}Tag").new(:tag => tag_name)
            self.send("#{Extlib::Inflection::underscore(self.class.to_s)}_tags") << p
            p.save unless self.new_record?
          end
        end
        
        def untag(tags)
          tags = [tags] unless tags.class == Array
          
          tags.each do |tag_name|
            tag_name = Tag.build(tag_name) if tag_name.class == String

            p = self.send("#{Extlib::Inflection::underscore(self.class.to_s)}_tags").first(:tag_id => tag_name.id)
            p.destroy if p
          end
        end
        
        def tags_list
          @tags_list || self.tags.collect {|t| t.name}.join(", ")
        end
        
        def tags_list=(list)
          @tags_list = list
          self.tags.each {|t| self.untag(t) }
          
          # Tag list generation
          list = list.split(",").collect {|s| s.strip}
          
          # Do the tagging here
          list.each { |t| self.tag(Tag.build(t)) }
        end
      end # InstanceMethods

    end # Taggable
  end # Is
end # DataMapper
