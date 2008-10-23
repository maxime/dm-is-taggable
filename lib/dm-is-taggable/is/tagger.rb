module DataMapper
  module Is
    module Tagger      
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

      def is_tagger(options={})
        unless self.respond_to?(:tagger?)
          # Add class-methods
          extend  DataMapper::Is::Tagger::ClassMethods
          
          # Add instance-methods
          include DataMapper::Is::Tagger::InstanceMethods
        
          cattr_accessor(:taggable_object_classes)
          self.taggable_object_classes = []
        end
        
        raise "options[:for] is missing" unless options[:for]
        
        add_taggable_object_classes(options[:for])
      end
      
      module ClassMethods
        def tagger?
          true
        end
        
        def add_taggable_object_classes(taggable_object_classes)
          taggable_object_classes.each do |taggable_object_class|
            self.taggable_object_classes << taggable_object_class
            self.has n, "#{taggable_object_class.storage_name.singular}_tags".intern
            self.has n, taggable_object_class.storage_name.intern, :through => "#{taggable_object_class.storage_name.singular}_tags".intern
          end
        end
      end # ClassMethods

      module InstanceMethods
        def tag(object, options={})
          raise "Object of type #{object.class} isn't taggable!" unless self.taggable_object_classes.include?(object.class)
          
          tags = options[:with]
          tags = [tags] if tags.class != Array
          
          tags.each do |tag|
            join_row_class = Extlib::Inflection::constantize("#{object.class.to_s}Tag")
            join_row = join_row_class.new(:tag => tag,
                                          Extlib::Inflection::underscore(self.class.to_s).intern => self)
            object.send("#{Extlib::Inflection::underscore(object.class.to_s)}_tags") << join_row
            join_row.save
          end
        end
      end # InstanceMethods

    end # Tagger
  end # Is
end # DataMapper