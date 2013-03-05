class UserData < SuperModel::Base
  include SoulmateRails::ModelAdditions

  autocomplete :name, :score => :id, :data => {:source => 'test'}
end
