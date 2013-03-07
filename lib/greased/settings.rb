
module Greased
  class Settings
    include Enumerable
    
    def initialize(application, environment, config = {})
      @application  = application
      @environment  = environment
      @config       = config
      @settings     = []
      
      refresh_settings!
    end
    
    def serialize
      @settings.collect(&:serialize).join("\n")
    end
    
    def apply!
      @settings.each(&:apply!)
      self
    end
    
    def puts!
      puts(*@settings.collect(&:serialize))
    end
    
    def each(&block)
      @settings.each(&block)
      self
    end
    
    protected
    
    def refresh_settings!
      @settings.clear
      @config.collect do |app_method, app_values|
        app_target = @application.send(app_method.to_sym)
        
        app_values.each do |method, values|
          parents = [app_method]
          
          if (target = app_target.send(method.to_sym)).is_a? ActiveSupport::OrderedOptions
            parents << method
          else
            values = { method => values }
            target = app_target
          end
          
          values.each do |key, value|
            @settings << Setting.new(@application, target, key, value, @environment, parents)
          end
        end
      end
    end
  end
end