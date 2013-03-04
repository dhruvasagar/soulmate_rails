module SoulmateRails
  module ModelAdditions
    extend ActiveSupport::Concern

    def update_index_for(attribute, options={})
      loader = instance_variable_get("@#{loader_for(attribute)}") || instance_variable_set("@#{loader_for(attribute)}", Soulmate::Loader.new(loader_for(attribute)))
      item = {
        'id' => "#{attribute}_#{self.id}",
        'term' => send(attribute),
        'score' => ( respond_to?(options[:score]) ? send(options[:score]) : options[:score] )
      }.merge( options[:aliases] ? ( respond_to?(options[:aliases]) ? send(options[:aliases]) : options[:aliases] ) : {} )
      # NOTE: Not supporting :data for now, will find a better way to use this later.
      # .merge( options[:data] ? ( respond_to?(options[:data]) ? send(options[:data]) : options[:data] ) : {} )
      loader.add(item, options)
    end

    def remove_index_for(attribute)
      loader = instance_variable_get("@#{loader_for(attribute)}") || instance_variable_set("@#{loader_for(attribute)}", Soulmate::Loader.new(loader_for(attribute)))
      loader.remove('id' => "#{attribute}_#{self.id}")
    end

    def loader_for(attribute)
      "#{self.class.normalized_class_name}_#{attribute}"
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
        matcher = instance_variable_get("@#{matcher_for(attribute)}") || instance_variable_set("@#{matcher_for(attribute)}", Soulmate::Matcher.new(matcher_for(attribute)))
        matches = matcher.matches_for_term(term, options)
        matches = matches.map do |match|
          find(match['id'].split('_')[-1].to_i) rescue nil
        end.compact
      end

      def matcher_for(attribute)
        "#{normalized_class_name}_#{attribute}"
      end

      def normalized_class_name
        self.name.gsub('::', '_').downcase
      end
    end
  end
end
