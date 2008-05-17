require 'pp'

# assumption:
#  #given always can #dup the return value.

module For
  EXAMPLES = {}
  RAN = []

  class ExampleFailed < RuntimeError; end
  class ExampleSkipped < RuntimeError; end

  class Example
    def initialize(desc, block)
      @desc = desc
      @block = block
      
      @run = false
      @failed = nil
      @skipped = false
      @return_value = nil
    end

    def run?
      @run
    end

    def green?
      run? && @failed.nil? && !skipped?
    end

    def skipped?
      @skipped
    end

    def failed?
      !!@failed
    end

    def call
      return @return_value  if run?
      begin
        @run = true
        @return_value = For.module_eval(&@block)
      rescue ExampleSkipped
        @skipped = true
      rescue => exc
        @failed = exc
      end
      RAN << self
      @return_value
    end

    def summary
      case
      when skipped?
        "SKIP"
      when failed?
        "FAIL " + @failed.message
      else
        "OK"
      end + "\t" + @desc
    end
  end

  class << self

    def example(desc, &block)
      EXAMPLES[desc] = Example.new(desc, block)
    end

    def given(desc)
      ex = EXAMPLES.fetch(desc) {
        raise IndexError, "no such example: #{desc}"
      }
      r = ex.call
      raise ExampleSkipped  unless ex.green?
      r.dup
    end

    def assert(cond)
      raise ExampleFailed, caller[0]  unless cond
    end

    def expect(exc, &block)
      begin
        block.call
      rescue *exc
        # do nothing
      rescue Object => e
        raise ExampleFailed, "got #{e}, expected #{exc}"
      else
        raise ExampleFailed, "#{exc} expected, got nothing"
      end
    end

    def all_examples
      EXAMPLES.each_value { |example|
        example.call  unless example.run?
      }
      RAN.each { |example|
        puts example.summary
      }
    end

  end

end
