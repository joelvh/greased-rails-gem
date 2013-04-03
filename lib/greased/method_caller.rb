module Greased
  class MethodCaller
    
    def initialize(operator = nil, options = {})
      @operator = operator
      @evaluations = []
      
      if @operator.nil?
        @evaluations << :default              
      elsif @operator == "="
        @evaluations << :assign
      else
        @evaluations << :evaluate
      end
      
      if options[:reassign]
        @evaluations << :assign
      end
    end
    
    def call(target, name, value)
      @evaluations.inject(value) do |result, evaluator|
        send(evaluator, target, name, result)
      end
    end
    
    protected
    
    def evaluate(target, name, value)
      target.send(name.to_sym).send(@operator.to_sym, value)
    end
    
    def assign(target, name, value)
      target.send(:"#{name}=", value)
    end
    
    def default(target, name, value)
      value = [value] unless value.is_a? Array
      target.send(name.to_sym, *value)
    end
    
  end
end