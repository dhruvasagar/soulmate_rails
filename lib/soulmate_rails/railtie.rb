module SoulmateRails
  class Railtie < Rails::Railtie
    initializer 'soulmate_rails.model_additions' do
      ActiveSupport.on_load :active_record do
        include ModelAdditions
      end
    end

    initializer 'soulmate_rails.set_configs' do |app|
      options = app.config.soulmate_rails

      Soulmate.redis = options[:redis] if options[:redis]
    end
  end
end
