# coding: utf-8

require 'spec_helper'

module Soulmate
  describe Matcher do
    before :each do
      items = []
      loader = Loader.new('venues')
      venues = File.open(TestRoot + '/samples/venues.json', 'r')
      venues.each_line do |venue|
        items << MultiJson.decode(venue)
      end
      loader.load(items)

      @matcher = Matcher.new('venues')
    end

    it 'should successfully return matches for given term' do
      results = @matcher.matches_for_term('stad')
      results.size.should eq(5)
      results.first['term'].should eq('Citi Field')
    end

    it 'should' do
      results = @matcher.matches_for_term('land shark stadium')
      results.size.should eq(1)
      results.first['term'].should eq('Sun Life Stadium')
    end

    it 'should successfully return matches with chinese' do
      results = @matcher.matches_for_term('中国')
      results.size.should eq(1)
      results.first['term'].should eq('中国佛山 李小龙')
    end
  end
end
