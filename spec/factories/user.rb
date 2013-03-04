class User < SuperModel::Base
  include SoulmateRails::ModelAdditions

  autocomplete :name, :score => :id
end

FactoryGirl.define do
  factory :user do
    name 'Dhruva Sagar'
  end
end
