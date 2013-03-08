
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
      puts(*list)
    end
    
    def list
      @settings.collect(&:serialize)
    end
    
    def each(&block)
      @settings.each(&block)
      self
    end
    
    protected
    
    def refresh_settings!
      @settings = @config.collect{ |key, value| Setting.from_config(@application, key, value, @environment) }.flatten
    end
  end
end