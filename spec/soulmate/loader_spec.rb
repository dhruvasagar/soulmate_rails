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
        expect(@items_loaded.size).to eq(7)
      end
    end

    context 'integration' do
      before :each do
        @matcher = Matcher.new('venues')
      end

      it 'should successfully remove the item' do
        @loader.load([])
        results = @matcher.matches_for_term('te', :cache => false)
        expect(results.size).to eq(0)

        @loader.add('id' => 1, 'term' => 'Testing this', 'score' => 10)
        results = @matcher.matches_for_term('te', :cache => false)
        expect(results.size).to eq(1)

        @loader.remove('id' => 1)
        results = @matcher.matches_for_term('te', :cache => false)
        expect(results.size).to eq(0)
      end

      it 'should successfully update items' do
        @loader.load([])
        @loader.add("id" => 1, "term" => "Testing this", "score" => 10)
        @loader.add("id" => 2, "term" => "Another Term", "score" => 9)
        @loader.add("id" => 3, "term" => "Something different", "score" => 5)

        results = @matcher.matches_for_term('te', :cache => false)
        expect(results.size).to eq(2)
        expect(results.first['term']).to eq('Testing this')
        expect(results.first['score']).to eq(10)

        @loader.add("id" => 1, "term" => "Updated", "score" => 5)
        results = @matcher.matches_for_term('te', :cache => false)
        expect(results.size).to eq(1)
        expect(results.first['term']).to eq('Another Term')
        expect(results.first['score']).to eq(9)
      end
    end
  end
end
