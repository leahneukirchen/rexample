require 'pp'

# assumption:
#  #given always can #dup the return value.

@examples = {}

class ExampleFailed < RuntimeError; end
class ExampleSkipped < RuntimeError; end

class Example
  @@ran = []
  def self.ran; @@ran; end

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
      @return_value = @block.call
    rescue ExampleSkipped
      @skipped = true
    rescue => exc
      @failed = exc
    end
    @@ran << self
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

def example(desc, &block)
  @examples[desc] = Example.new(desc, block)
end

def given(desc)
  ex = @examples.fetch(desc) {
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

def for_example
  @examples.each_value { |example|
    example.call  unless example.run?
  }
  Example.ran.each { |example|
    puts example.summary
  }
end
