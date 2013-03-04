require 'spec_helper'

module SoulmateRails
  class User < SuperModel::Base
    include ModelAdditions

    autocomplete :name, :score => :id
  end

  describe ModelAdditions do
    context 'single autocomplete' do
      before :each do
        @user = User.create(:name => 'Dhruva Sagar')
      end

      it 'should successfully search by name' do
        users = User.search_by_name('dhruv')
        user = users.first
        user.should eq(@user)
      end
    end

    context 'multiple autocompletes' do
      before :each do
        # Define another autocomplete for country
        User.autocomplete(:country, :score => :id)
        @user = User.create(:name => 'Dhruva Sagar', :country => 'India')
      end

      it 'should successfully search by name as well as country' do
        users = User.search_by_name('dhr')
        user = users.first
        user.should eq(@user)

        users = User.search_by_country('ind')
        user = users.first
        user.should eq(@user)
      end
    end

    after :each do
      User.destroy_all
    end
  end
end
