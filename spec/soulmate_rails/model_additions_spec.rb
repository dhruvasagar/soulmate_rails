require 'spec_helper'

module SoulmateRails
  describe ModelAdditions do
    context 'autocomplete for name' do
      before :each do
        @user = UserSingle.create(:name => 'Dhruva Sagar')
      end

      it 'should successfully search by name' do
        # By first name
        users = UserSingle.search_by_name('dhr')
        user = users.first
        expect(user).to eq(@user)

        # By last name
        users = UserSingle.search_by_name('sag')
        user = users.first
        expect(user).to eq(@user)
      end

      after :each do
        UserSingle.destroy_all
      end
    end

    context 'autocomplete for name and country' do
      before :each do
        @user = UserMultiple.create(:name => 'Dhruva Sagar', :country => 'India')
      end

      it 'should successfully search by name as well as country' do
        users = UserMultiple.search_by_name('dhr')
        user = users.first
        expect(user).to eq(@user)

        users = UserMultiple.search_by_country('ind')
        user = users.first
        expect(user).to eq(@user)
      end

      after :each do
        UserMultiple.destroy_all
      end
    end

    context 'autocomplete name with aliases' do
      before :each do
        @user = UserAliases.create(:name => 'Dhruva Sagar')
      end

      it 'should successfully search by name'  do
        # By reverse of my first name
        users = UserAliases.search_by_name('avu')
        user = users.first
        expect(user).to eq(@user)

        # By reverse of my last name
        users = UserAliases.search_by_name('rag')
        user = users.first
        expect(user).to eq(@user)
      end

      after :each do
        UserAliases.destroy_all
      end
    end

    context 'autocomplete name with additional data' do
      before :each do
        @user = UserData.create(:name => 'Dhruva Sagar', :country => 'India')
      end

      it 'should successfully search by name and set data' do
        users = UserData.search_by_name('dhr')
        user = users.first
        expect(user).to eq(@user)
        expect(user.soulmate_data).to eq({:source => 'test'})
      end

      after :each do
        UserData.destroy_all
      end
    end
  end
end
