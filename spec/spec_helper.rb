require 'supermodel'
require 'mock_redis'
require 'factory_girl'
require 'soulmate_rails'

TestRoot = File.expand_path(File.dirname(__FILE__))

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.order = 'random'
  config.color_enabled = true

  config.include FactoryGirl::Syntax::Methods

  config.before(:each) do
    redis = MockRedis.new
    redis.flushdb
    Soulmate.redis = redis
  end
end

