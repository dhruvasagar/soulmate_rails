require 'spec_helper'

module SoulmateRails
  describe ModelAdditions do
    before :each do
      @user = FactoryGirl.create(:user)
    end

    it 'should successfully search' do
      user = User.search_by_name('dhruv')
      user = user.first
      user.id.should eq(@user.id)
      user.name.should eq('Dhruva Sagar')
    end

    after :each do
      User.destroy_all
    end
  end
end
