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
        'term' => send(attribute).encode('UTF-8'),
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

        # use only redis cache without touching backend database
        define_singleton_method "search_cache_by_#{attribute}" do |term, *opts|
          opts = opts.empty? ? {} : opts.first
          search_cache_by(attribute, term, opts)
        end

        # define utility function to clean out cached data
        define_singleton_method "flush_cache_by_#{attribute}" do
          flush_cache(attribute)
        end

        # define utility function to reload data from database
        define_singleton_method "reload_cache_by_#{attribute}" do |options|
          reload_cache(attribute, options)
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

      def flush_cache(attribute)
        loader = instance_variable_get("@#{name_for(attribute)}") || instance_variable_set("@#{name_for(attribute)}", Soulmate::Loader.new(name_for(attribute)))

        # delete the sorted sets for this type
        phrases = Soulmate.redis.keys(loader.base + "*")

        # delete cached sets for previous
        cache_phrases = Soulmate.redis.keys(loader.cachebase + "*")

        Soulmate.redis.pipelined do
          phrases.each do |p|
            Soulmate.redis.del(p)
          end

          cache_phrases.each do |p|
            Soulmate.redis.del(p)
          end
        end

        # delete the data stored for this type
        Soulmate.redis.del(loader.database)
      end

      # example call: City.reload_cache(:name, {:score => :autocomplete_score, :data => :autocomplete_data})
      # example call: City.reload_cache_by_name({:score => :autocomplete_score, :data => :autocomplete_data})
      def reload_cache(attribute, options)
        flush_cache(attribute)
        self.all.each { |object| object.update_index_for(attribute, options) }
      end

      # define a mathod to return results from cache instead of connecting to backend database
      def search_cache_by(attribute, term, options={})
        matcher = instance_variable_get("@#{name_for(attribute)}_matcher") || instance_variable_set("@#{name_for(attribute)}_matcher", Soulmate::Matcher.new(name_for(attribute)))
        matches = matcher.matches_for_term(term, options)

        res = []
        matches.each {|m| res << [m['id'].split('_')[-1].to_i, m['data']] }

        res
      end
    end
  end
end
