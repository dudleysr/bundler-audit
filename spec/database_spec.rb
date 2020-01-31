require 'spec_helper'
require 'bundler/audit/database'
require 'tmpdir'

describe Bundler::Audit::Database do
  let(:advisory_paths) do
    Dir[File.join(described_class.path, 'gems/*/*.yml')].sort
  end

  describe "path" do
    subject { described_class.path }

    it "must default to DEFAULT_PATH" do
      expect(subject).to be == described_class::DEFAULT_PATH
    end
  end

  describe "update!" do
    context "when the database does not exist" do
      before do
        described_class.path = Dir::Tmpname.create('ruby-advisory-db-') { }
      end

      it "must clone the database" do
        expect_update_to_clone_repo!

        Bundler::Audit::Database.update!(quiet: false)
      end

      after do
        FileUtils.rm_rf(described_class.path)
        described_class.path = test_ruby_advisory_db
      end
    end

    context "when the database already exists" do
      it "must update the database" do
        expect_update_to_update_repo!

        Bundler::Audit::Database.update!(quiet: false)
      end
    end
  end

  describe "#initialize" do
    context "when given no arguments" do
      subject { described_class.new }

      it "should default path to path" do
        expect(subject.path).to eq(described_class.path)
      end
    end

    context "when given a directory" do
      let(:path ) { Dir.tmpdir }

      subject { described_class.new(path) }

      it "should set #path" do
        expect(subject.path).to eq(path)
      end
    end

    context "when given an invalid directory" do
      it "should raise an ArgumentError" do
        expect {
          described_class.new('/foo/bar/baz')
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#check_gem" do
    let(:gem) do
      Gem::Specification.new do |s|
        s.name    = 'actionpack'
        s.version = '3.1.9'
      end
    end

    context "when given a block" do
      it "should yield every advisory effecting the gem" do
        advisories = []

        subject.check_gem(gem) do |advisory|
          advisories << advisory
        end

        expect(advisories).not_to be_empty
        expect(advisories.all? { |advisory|
          advisory.kind_of?(Bundler::Audit::Advisory)
        }).to be_truthy
      end
    end

    context "when given no block" do
      it "should return an Enumerator" do
        expect(subject.check_gem(gem)).to be_kind_of(Enumerable)
      end
    end
  end

  describe "#size" do
    it { expect(subject.size).to eq advisory_paths.count }
  end

  describe "#advisories" do
    it "should return a list of all advisories." do
      actual_advisories = Bundler::Audit::Database.new.
        advisories.
        map(&:path).
        sort

      expect(actual_advisories).to eq advisory_paths
    end
  end

  describe "#to_s" do
    it "should return the Database path" do
      expect(subject.to_s).to eq(subject.path)
    end
  end

  describe "#inspect" do
    it "should produce a Ruby-ish instance descriptor" do
      expect(Bundler::Audit::Database.new.inspect).to eq("#<Bundler::Audit::Database:#{described_class.path}>")
    end
  end
end
