module SoulmateRails
  class Railtie < Rails::Railtie
    initializer 'soulmate_rails.model_additions' do
      ActiveSupport.on_load :active_record do
        include ModelAdditions
      end
    end

    initializer 'soulmate_rails.set_configs' do |app|
      # configuration file for redis server and soulmate
      redis_config_file = "config/redis_server.yml"
      if File.exists?(redis_config_file)
        file = YAML.load_file(redis_config_file)
        Soulmate.redis = file[:redis_url] if file[:redis_url]
        Soulmate.cache_time = file[:cache_time] if file[:cache_time]
        Soulmate.max_results = file[:max_results] if file[:max_results]
      end
      # configuration file for stopping words
      stop_words_file = "config/stopping_words.yml"
      if File.exists?(stop_words_file)
        stopping_words = []
        s_file = YAML.load_file(stop_words_file)
        s_file.each_line { |line| stopping_words.push(line) }
        Soulmate.stop_words = stopping_words
      end
    end
  end
end
