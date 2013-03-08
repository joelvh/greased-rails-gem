
module Greased
  class Setting
    
    DEFAULT_OPERATOR = "="
    OPERATIONS = {
      "<<"    => lambda{ |target, name, value| target.send(:"#{name}<<", value) },
      "+="    => lambda{ |target, name, value| target.send(:"#{name}=", target.send(:"#{name}") + value) },
      "-="    => lambda{ |target, name, value| target.send(:"#{name}=", target.send(:"#{name}") - value) },
      "*="    => lambda{ |target, name, value| target.send(:"#{name}=", target.send(:"#{name}") * value) },
      "="     => lambda{ |target, name, value| target.send(:"#{name}=", value) },
      "send"  => lambda{ |target, name, value| target.send(name.to_sym, *value) }
    }
    OPERATION_VALIDATORS = {
      "send" => lambda{|target, name, value| raise "Value for the 'send' operator must be an array of method parameters" unless value.is_a? Array }
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
      raise "Unknown operator (#{operator}) for setting option: #{name}"  unless OPERATIONS.keys.include? operator
      OPERATION_VALIDATORS[operator].call(@target, name, value)           if OPERATION_VALIDATORS.keys.include? operator
      OPERATIONS[operator].call(@target, name, value)
      
      self
    end
    
    class << self
      
      def from_config(app, property_name, property_values, env)
        app_target  = app.send(property_name.to_sym)
        
        property_values.collect do |setting_name, setting_values|
          parents = Array.wrap(property_name)
          
          if (target = app_target.send(setting_name.to_sym)).is_a? ActiveSupport::OrderedOptions
            parents << setting_name
          else
            setting_values  = { setting_name => setting_values }
            target          = app_target
          end
          
          setting_values.collect{ |key, value| new(app, target, key, value, env, parents) }
        end.flatten
      end
      
    end
    
  end
end