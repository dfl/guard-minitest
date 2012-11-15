# encoding: utf-8
require 'guard'
require 'guard/guard'

module Guard
  class Minitest < Guard

    autoload :Runner,    'guard/minitest/runner'
    autoload :Inspector, 'guard/minitest/inspector'

    def initialize(watchers = [], options = {})
      super

      @options = {
        :all_on_start   => true,
        :all_after_pass => true,
      }.update(options)

      @runner = Runner.new(options)
      @inspector = Inspector.new(@runner.test_folders, @runner.test_file_patterns)
    end

    def start
      run_all if @options[:all_on_start]
      true
    end

    def stop
      true
    end

    def reload
      true
    end

    def run_all
       paths = @inspector.clean_all
       return @runner.run(paths, :message => 'Running all tests') unless paths.empty?
       true
     end

     def run_on_change(paths = [])
       paths = @inspector.clean(paths)
       passed = @runner.run(paths)
       run_all if passed && @options[:all_after_pass]
       return passed unless paths.empty?
       true
     end
  end
end
