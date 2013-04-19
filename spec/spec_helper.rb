require 'rspec'
require 'supermodel'
require 'mock_redis'
require 'soulmate_rails'

require 'samples/models/user_single'
require 'samples/models/user_multiple'
require 'samples/models/user_aliases'
require 'samples/models/user_data'

TestRoot = File.expand_path(File.dirname(__FILE__))

RSpec.configure do |config|
  config.order = 'random'
  config.color_enabled = true

  config.before(:suite) do
    redis = MockRedis.new
    redis.flushdb
    Soulmate.redis = redis
  end
end
