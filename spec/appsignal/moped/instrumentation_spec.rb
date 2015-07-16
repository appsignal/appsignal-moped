require 'spec_helper'

module AppsignalSpec
  class HashIsh < Hash
  end
end

describe Appsignal::Moped::Instrumentation do
  let(:session) do
    Moped::Session.new(%w[127.0.0.1:27017], database: 'moped_test')
  end
  before(:all) do
    @events = []
    ActiveSupport::Notifications.subscribe('query.moped') do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end
  end
  let(:event) { @events.last }

  context "instrument an insert" do
    before  { session['users'].insert({:name => 'test'}) }
    subject { event.payload[:ops].first }

    it "should return an insert operation" do
      should be_a Moped::Protocol::Insert
    end

    its(:full_collection_name) { should == 'moped_test.users' }
    its(:documents)            { should == [{:name => 'test'}] }

    after { session['users'].find.remove_all }
  end

  context "instrument a find" do
    before  { session['users'].find(:name => 'Pete').skip(1).one }
    subject { event.payload[:ops].first }

    it "should return a query operation" do
      should be_a Moped::Protocol::Query
    end

    its(:full_collection_name) { should == 'moped_test.users' }
    its(:selector)             { should == {:name => 'Pete'} }
    its(:skip)                 { should == 1 }
    its(:limit)                { should == -1 }
  end

  describe "deep clone" do
    let(:find_hash) { AppsignalSpec::HashIsh.new }
    before          { find_hash[:name] = 'Pete' }
    before          { find_hash[:query] = /Pete/ }
    subject         { Appsignal::Moped::Instrumentation.deep_clone(find_hash) }

    it "should clone subclassed hashes to a 'normal' hash" do
      should be_a Hash
      should_not be_a AppsignalSpec::HashIsh
    end

    it "should still have the hash values" do
      should == {:name => 'Pete', :query => /Pete/}
    end
  end
end
