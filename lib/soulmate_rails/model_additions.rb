module SoulmateRails
  module ModelAdditions
    extend ActiveSupport::Concern

    included do
      class_eval do
        attr_accessor :soulmate_data
      end
    end

    def update_index_for(attribute, options={})
      loader = instance_variable_get("@#{self.class.name_for(attribute)}_loader") || instance_variable_set("@#{self.class.name_for(attribute)}_loader", Soulmate::Loader.new(self.class.name_for(attribute)))
      item = {
        'id' => "#{attribute}_#{self.id}",
        'term' => send(attribute),
        'score' => ( respond_to?(options[:score]) ? send(options[:score]) : options[:score] )
      }

      if options[:aliases]
        if options[:aliases].is_a?(Array)
          item.merge!({'aliases' => options[:aliases]})
        elsif respond_to?(options[:aliases])
          aliases = send(options[:aliases])
          item.merge!({'aliases' => aliases}) if aliases && aliases.is_a?(Array)
        end
      end

      if options[:data]
        if options[:data].is_a?(Hash)
          item.merge!({'data' => options[:data]})
        elsif respond_to?(options[:data])
          item.merge!({'data' => send(options[:data])})
        elsif options[:data].is_a?(String)
          item.merge!({'data' => options[:data]})
        end
      end

      loader.add(item)
    end

    def remove_index_for(attribute)
      loader = instance_variable_get("@#{self.class.name_for(attribute)}") || instance_variable_set("@#{self.class.name_for(attribute)}", Soulmate::Loader.new(self.class.name_for(attribute)))
      loader.remove('id' => "#{attribute}_#{self.id}")
    end

    module ClassMethods
      def autocomplete(attribute, options={})
        define_method "update_index_for_#{attribute}" do
          update_index_for(attribute, options)
        end
        after_save "update_index_for_#{attribute}"

        define_method "remove_index_for_#{attribute}" do
          remove_index_for(attribute)
        end
        before_destroy "remove_index_for_#{attribute}"

        define_singleton_method "search_by_#{attribute}" do |term, *opts|
          opts = opts.empty? ? {} : opts.first
          search_by(attribute, term, opts)
        end
      end

      def search_by(attribute, term, options={})
        matcher = instance_variable_get("@#{name_for(attribute)}_matcher") || instance_variable_set("@#{name_for(attribute)}_matcher", Soulmate::Matcher.new(name_for(attribute)))
        matches = matcher.matches_for_term(term, options)

        hash = {}
        matches.each {|m| hash[m['id'].split('_')[-1].to_i] = m}

        where(:id => hash.keys).map do |object|
          object.soulmate_data = hash[object.id]['data'].symbolize_keys if hash[object.id] && hash[object.id]['data']
          object
        end
      end

      def name_for(attribute)
        "#{normalized_class_name}_#{attribute}"
      end

      def normalized_class_name
        self.name.gsub('::', '_').downcase
      end
    end
  end
end
