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
      expect(results.size).to eq(5)
      expect(results.first['term']).to eq('Citi Field')
    end

    it 'should successfully return matches with aliases' do
      results = @matcher.matches_for_term('land shark stadium')
      expect(results.size).to eq(1)
      expect(results.first['term']).to eq('Sun Life Stadium')
    end

    it 'should successfully return matches with chinese' do
      results = @matcher.matches_for_term('中国')
      expect(results.size).to eq(1)
      expect(results.first['term']).to eq('中国佛山 李小龙')
    end
  end
end
