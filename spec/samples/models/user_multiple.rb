class UserMultiple < SuperModel::Base
  include SoulmateRails::ModelAdditions

  autocomplete :name, :score => :id
  autocomplete :country, :score => :id
end
