# encoding: utf-8

require 'rubygems'

begin
  require 'bundler/setup'
rescue LoadError => e
  abort e.message
end

require 'rake'
require 'time'

require 'rubygems/tasks'
Gem::Tasks.new

directory 'spec/data/ruby-advisory-db' do
  sh 'git clone https://github.com/rubysec/ruby-advisory-db spec/data/ruby-advisory-db'
end
task 'spec:ruby-advisory-db' => 'spec/data/ruby-advisory-db'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

namespace :spec do
  task :bundle do
    root = 'spec/bundle'

    %w[secure unpatched_gems insecure_sources].each do |bundle|
      chdir(File.join(root,bundle)) do
        sh 'unset BUNDLE_BIN_PATH BUNDLE_GEMFILE RUBYOPT && bundle install --path ../../../vendor/bundle'
      end
    end
  end
end
task :spec => %w[spec:ruby-advisory-db spec:bundle]

task :test    => :spec
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new  
task :doc => :yard
