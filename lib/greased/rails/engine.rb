#require 'greased-rails'
#require 'rails'

module Greased
  module Rails
    class Engine < ::Rails::Engine
      
      # Load rake tasks
      rake_tasks do
        
        Greased.logger.level = Logger::DEBUG if ::Rails.env.development?
        
        path = Greased.file_path(File.dirname(__FILE__), '../../../tasks/')
        
        Dir["#{path}/*.rake"].each do |filename|
          load filename
        end
      end
      
    end
  end
end