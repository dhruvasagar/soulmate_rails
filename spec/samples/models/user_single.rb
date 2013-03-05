class UserSingle < SuperModel::Base
  include SoulmateRails::ModelAdditions

  autocomplete :name, :score => :id
end
