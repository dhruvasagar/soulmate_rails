class UserAliases < SuperModel::Base
  include SoulmateRails::ModelAdditions

  autocomplete :name, :score => :id, :aliases => :name_aliases

  def name_aliases
    self.name.split(' ').map(&:reverse)
  end
end
