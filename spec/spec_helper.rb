require 'simplecov'
SimpleCov.start

require 'rspec'
require 'bundler/audit/version'
require 'bundler/audit/database'

module Helpers
  def sh(command, options={})
    Bundler.with_clean_env do
      result = `#{command} 2>&1`
      raise "FAILED #{command}\n#{result}" if $?.success? == !!options[:fail]
      result
    end
  end

  def decolorize(string)
    string.gsub(/\e\[\d+m/, "")
  end

  def test_ruby_advisory_db
    File.expand_path('../data/ruby-advisory-db',__FILE__)
  end

  def expect_update_to_clone_repo!
    expect(Bundler::Audit::Database).
      to receive(:system).
      with('git', 'clone', Bundler::Audit::Database::URL, Bundler::Audit::Database.path).
      and_call_original
  end

  def expect_update_to_update_repo!
    expect(Bundler::Audit::Database).
      to receive(:system).
      with('git', 'pull', 'origin', 'master').
      and_call_original
  end
end

include Bundler::Audit

RSpec.configure do |config|
  include Helpers

  config.before(:suite) do
    Bundler::Audit::Database.path = test_ruby_advisory_db
  end
end
