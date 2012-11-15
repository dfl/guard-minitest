# encoding: utf-8
require 'spec_helper'

describe Guard::Minitest do
  subject { Guard::Minitest }

  let(:runner) { stub('runner', :test_folders => [], :test_file_patterns => []) }
  let(:inspector) { stub('inspector') }
  let(:guard) { subject.new }

  before(:each) do
    Guard::Minitest::Runner.stubs(:new).returns(runner)
    Guard::Minitest::Inspector.stubs(:new).returns(inspector)
  end

  after(:each) do
    Guard::Minitest::Runner.unstub(:new)
    Guard::Minitest::Inspector.unstub(:new)
  end

  describe 'initialization' do

    it 'should initialize runner with options' do
      Guard::Minitest::Runner.expects(:new).with({}).returns(runner)
      subject.new
    end

    it 'should initialize inspector with options' do
      Guard::Minitest::Inspector.expects(:new).with(runner.test_folders, runner.test_file_patterns).returns(inspector)
      subject.new
    end

  end

  describe 'start' do

    it 'should return true' do
      guard.start.must_equal true
    end
    
    it 'should not run_all if all_on_start is false' do
      Guard::Minitest.stubs(:options).returns( {:all_on_start => false} )
      Guard::Minitest.expects(:run_all).never
      guard.start
    end

    it 'should run_all if all_on_start is true' do
      Guard::Minitest.stubs(:options).returns( {:all_on_start => true} )
      Guard::Minitest.expects(:run_all).once
      guard.start
    end

  end

  describe 'stop' do

    it 'should return true' do
      guard.stop.must_equal true
    end

  end

  describe 'reload' do

    it 'should return true' do
      guard.reload.must_equal true
    end

  end

  describe 'run_all' do

    it 'should run all tests' do
      inspector.stubs(:clean_all).returns(['test/guard/minitest/test_inspector.rb', 'test/guard/test_minitest.rb'])
      runner.expects(:run).with(['test/guard/minitest/test_inspector.rb', 'test/guard/test_minitest.rb'], {:message => 'Running all tests'}).returns(true)
      guard.run_all.must_equal true
    end

  end

  describe 'run_on_change' do

    it 'should run minitest in paths' do
      Guard::Minitest.stubs(:options).returns( {:all_after_pass => false} )
      inspector.stubs(:clean).with(['test/guard/minitest/test_inspector.rb']).returns(['test/guard/minitest/test_inspector.rb'])
      runner.expects(:run).with(['test/guard/minitest/test_inspector.rb']).returns(true)
      guard.run_on_change(['test/guard/minitest/test_inspector.rb']).must_equal true
    end

    it 'should run_all if passed and all_after_pass' do
      Guard::Minitest.stubs(:options).returns( {:all_after_pass => true} )
      runner.stubs(:run).returns( true ) # passed
      Guard::Minitest.expects(:run_all).once
      guard.run_on_change
    end

    it 'should not run_all if passed and all_after_pass is false' do
      Guard::Minitest.stubs(:options).returns( {:all_after_pass => false} )
      runner.stubs(:run).returns( true ) # passed
      Guard::Minitest.expects(:run_all).never
      guard.start
    end

    it 'should not run_all if failed' do
      Guard::Minitest.stubs(:options).returns( {:all_after_pass => true} )
      runner.stubs(:run).returns( false ) # failed
      Guard::Minitest.expects(:run_all).never
      guard.run_on_change
    end

  end
end
