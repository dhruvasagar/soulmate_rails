require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

require File.join(File.expand_path('../lib', __FILE__), 'soulmate_rails', 'version')

RSpec::Core::RakeTask.new
task :default => :spec

desc 'Builds the gem'
task :build do
  sh 'gem build soulmate_rails.gemspec'
  Dir.mkdir('pkg') unless File.directory?('pkg')
  sh "mv soulmate_rails-#{SoulmateRails::VERSION}.gem pkg/"
end

desc 'Builds and Installs the gem'
task :install => :build do
  sh "gem install pkg/soulmate_rails-#{SoulmateRails::VERSION}.gem"
end

desc 'Open an irb session preloaded with this library'
task :console do
  sh 'irb -rubygems -I lib -r soulmate_rails.rb'
end

desc 'Release the gem'
task :release => :build do
  sh "git tag -a 'v#{SoulmateRails::VERSION}' -m 'Version #{SoulmateRails::VERSION}'"
  sh 'git push origin master --tags'
  sh "gem push pkg/soulmate_rails-#{SoulmateRails::VERSION}.gem"
end
