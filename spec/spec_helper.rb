require 'supermodel'
require 'mock_redis'
require 'soulmate_rails'

TestRoot = File.expand_path(File.dirname(__FILE__))

RSpec.configure do |config|
  config.order = 'random'
  config.color_enabled = true

  config.before(:each) do
    redis = MockRedis.new
    redis.flushdb
    Soulmate.redis = redis
  end
end

