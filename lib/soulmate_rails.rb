require 'uri'
require 'redis'
require 'multi_json'

require 'active_support/concern'

require 'soulmate/helpers'
require 'soulmate/base'
require 'soulmate/matcher'
require 'soulmate/loader'

require 'soulmate_rails/model_additions'
require 'soulmate_rails/railtie' if defined? Rails

module Soulmate

  extend self

  MIN_COMPLETE = 2

  DEFAULT_STOP_WORDS = ["vs", "at", "the"]

  def redis=(server)
    if server.is_a?(String)
      @redis = nil
      @redis_url = server
    else
      @redis = server
    end

    redis
  end

  def redis
    @redis ||= (
      url = URI(@redis_url || ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0")

      ::Redis.new({
        :host => url.host,
        :port => url.port,
        :db => url.path[1..-1],
        :password => url.password
      })
    )
  end

  def stop_words
    @stop_words ||= DEFAULT_STOP_WORDS
  end

  def stop_words=(arr)
    @stop_words = Array(arr).flatten
  end

  def min_complete
    @min_complete ||= MIN_COMPLETE
  end

  def min_complete=(min_len)
    if min_len.is_a? Integer
      @min_complete = min_len unless min_len < 1 || min_len > 5
    end
  end

  def cache_time
    # default to 10 minutes
    @cache_time ||= 10 * 60
  end

  def cache_time=(time_period)
    if time_period.is_a? Integer
      @cache_time = time_period unless time_period < 1
    end
  end

  def cache_namespace
    @cache_namespace
  end

  def cache_namespace=(namespace)
    @cache_namespace = namespace
  end

  def max_results
    # default to 10 max results returned
    @max_results ||= 10
  end

  def max_results=(max_num)
    if max_num.is_a? Integer
      @max_results = max_num unless max_num < 1
    end
  end
end
