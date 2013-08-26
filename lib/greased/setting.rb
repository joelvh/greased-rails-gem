
module Greased
  class Setting
    DEFAULT_OPERATOR = "="
    OPERATIONS = {
      "<<"    => MethodCaller.new("<<"),
      "+="    => MethodCaller.new("+", :reassign => true),
      "-="    => MethodCaller.new("-", :reassign => true),
      "*="    => MethodCaller.new("*", :reassign => true),
      "="     => MethodCaller.new("="),
      "call"  => MethodCaller.new,
      "send"  => MethodCaller.new
    }
    
    attr_reader :name, :value, :operator, :app, :env
    
    def initialize(app, target, name, value, env, parent_methods = [])
      @name, @operator = name.split(/\s+/, 2)
      @value          = value
      @operator       ||= DEFAULT_OPERATOR
      @target         = target
      @app            = app
      @env            = env
      @parent_methods = parent_methods
    end
    
    def serialize
      #"#{(@parent_methods + [name]).join('.')} #{operator} #{PP.pp(value, '').sub(/^([\[\{])/, "\1\n").sub(/([\]\}])$/, "\n\1")})}"
      "#{(@parent_methods + [name]).join('.')} #{operator} #{PP.pp(value, '').sub(/^([\[\{])/, "\\1\n ").sub(/([\]\}])$/, "\n\\1")}"
    end
    
    def apply!
      raise "Unknown operator (#{operator}) for setting option: #{name}" unless OPERATIONS.keys.include? operator
      OPERATIONS[operator].call(@target, name, value)
      
      self
    end
    
    class << self
      
      def from_config(app, property_name, property_values, env)
        app_target  = app.send(property_name.to_sym)
        
        property_values.collect do |setting_name, setting_values|
          parents = Array.wrap(property_name)
          
          begin
            if (target = app_target.send(setting_name.to_sym)).is_a? ActiveSupport::OrderedOptions
              parents << setting_name
            else
              setting_values  = { setting_name => setting_values }
              target          = app_target
            end
            
            setting_values.collect{ |key, value| new(app, target, key, value, env, parents) }
          rescue NoMethodError => ex
            puts "Warning! Configuration section #{app_target} doesn't exist: #{ex}"
            
            []
          end
        end.flatten
      end
      
    end
    
  end
end