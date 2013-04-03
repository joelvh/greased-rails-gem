
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
    
    def apply!
      each(&:apply!)
    end
    
    def list
      @settings.map(&:serialize)
    end
    
    def serialize
      list.join("\n")
    end
    
    def each(&block)
      @settings.each(&block)
      self
    end
    
    protected
    
    def refresh_settings!
      @settings = @config.map{|key, value| Setting.from_config(@application, key, value, @environment)}.flatten
    end
  end
end