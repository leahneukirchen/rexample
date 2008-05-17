require 'rexample'

class Stack < Array
  def pop
    raise ArgumentError  if empty?
    super
  end
end

example "an empty stack" do
  stack = Stack.new
  assert stack.empty?
  
  stack
end

example "pushing an element" do
  stack = given "an empty stack"
  stack.push :foo
  
  assert !stack.empty?
  assert stack.size == 1

  stack
end

example "popping an element" do
  stack = given "pushing an element"
  value = stack.pop
  
  assert value == :foo
  assert stack.empty?

  stack
end

example "popping on empty stack fails" do
  stack = given "an empty stack"
  expect ArgumentError do
    stack.pop
  end
end

for_example
