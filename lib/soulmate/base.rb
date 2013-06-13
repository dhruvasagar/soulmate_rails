module Soulmate
  class Base
    include Helpers

    attr_accessor :type

    def initialize(type)
      @type = normalize(type)
    end

    def base
      "soulmate-index:#{Soulmate.cache_namespace}_#{type}"
    end

    def database
      "soulmate-data:#{Soulmate.cache_namespace}_#{type}"
    end

    def cachebase
      "soulmate-cache:#{Soulmate.cache_namespace}_#{type}"
    end
  end
end
