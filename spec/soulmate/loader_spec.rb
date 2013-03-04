require 'spec_helper'

module Soulmate
  describe Loader do
    before :each do
      @loader = Loader.new('venues')
    end

    context 'add' do
      it 'should successfully add acceptable value' do
        expect {
          @loader.add({"id" => 11,"term" => "Dodger Stadium","score" => 84,"data" => {"url" => "\/dodger-stadium-tickets\/","subtitle" => "Los Angeles, CA"},"aliases" => ["Chavez Ravine"]})
        }.to_not raise_error
      end

      context 'invalid item' do
        it 'should raise ArgumentError if id is missing' do
          expect {
            @loader.add({"term" => "Dodger Stadium","score" => 84,"data" => {"url" => "\/dodger-stadium-tickets\/","subtitle" => "Los Angeles, CA"},"aliases" => ["Chavez Ravine"]})
          }.to raise_error
        end

        it 'should raise ArgumentError if term is missing' do
          expect {
            @loader.add({"id" => 11, "score" => 84,"data" => {"url" => "\/dodger-stadium-tickets\/","subtitle" => "Los Angeles, CA"},"aliases" => ["Chavez Ravine"]})
          }.to raise_error(ArgumentError)
        end
      end
    end

    context 'load' do
      before :each do
        @items = []
        venues = File.open(TestRoot + '/samples/venues.json', 'r')
        venues.each_line do |venue|
          @items << MultiJson.decode(venue)
        end
        @items_loaded = @loader.load(@items)
      end

      it 'should load values' do
        @items_loaded.size.should eq(7)
      end
    end

    context 'integration' do
      before :each do
        @matcher = Matcher.new('venues')
      end

      it 'should successfully remove the item' do
        @loader.load([])
        results = @matcher.matches_for_term('te', :cache => false)
        results.size.should eq(0)

        @loader.add('id' => 1, 'term' => 'Testing this', 'score' => 10)
        results = @matcher.matches_for_term('te', :cache => false)
        results.size.should eq(1)

        @loader.remove('id' => 1)
        results = @matcher.matches_for_term('te', :cache => false)
        results.size.should eq(0)
      end

      it 'should successfully update items' do
        @loader.load([])
        @loader.add("id" => 1, "term" => "Testing this", "score" => 10)
        @loader.add("id" => 2, "term" => "Another Term", "score" => 9)
        @loader.add("id" => 3, "term" => "Something different", "score" => 5)

        results = @matcher.matches_for_term('te', :cache => false)
        results.size.should eq(2)
        results.first['term'].should eq('Testing this')
        results.first['score'].should eq(10)

        @loader.add("id" => 1, "term" => "Updated", "score" => 5)
        results = @matcher.matches_for_term('te', :cache => false)
        results.size.should eq(1)
        results.first['term'].should eq('Another Term')
        results.first['score'].should eq(9)
      end
    end
  end
end
