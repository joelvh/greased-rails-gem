#require 'greased-rails'
#require 'rails'
require 'greased'

module Greased
  module Rails
    class Engine < ::Rails::Engine
      
      #http://guides.rubyonrails.org/configuring.html
      #before_configuration
      #before_initialize - before initialization
      #to_prepare - after railties and application initializers, before eager loading and middleware (on each request in dev)
      #before_eager_load - default behavior in production
      #after_initialize - after application initializes - BEFORE application initializers
      
      #app.config.before_configuration
      #:load_environment_hook
      config.before_configuration do |application|
        
        Greased.logger.level = Logger::DEBUG if ::Rails.env.development?
        
        options     = Options.find(::Rails.root)
        applicator  = Applicator.new(application, options)
        
        applicator.apply_variables_to_environment!(overwrite: false)
        
        if ::Rails.env.development?
          
          Greased.logger.debug " "
          Greased.logger.debug "## GREASED [#{applicator.env.upcase}] #{'#' * (55 - applicator.env.size)}"
          Greased.logger.debug "#                                                                   #"
          Greased.logger.debug "#                      ... loaded options ...                       #"
          Greased.logger.debug "#                                                                   #"
          Greased.logger.debug "#####################################################################"
          Greased.logger.debug " "
          
          Greased.logger.debug " "
          Greased.logger.debug "#####################################################################"
          Greased.logger.debug " "
          
          ##########################
          
          Greased.logger.debug " "
          Greased.logger.debug "## GREASED [#{applicator.env.upcase}] #{'#' * (55 - applicator.env.size)}"
          Greased.logger.debug "#                                                                   #"
          Greased.logger.debug "#              ... loading environment variables ...                #"
          Greased.logger.debug "#                                                                   #"
          Greased.logger.debug "#####################################################################"
          Greased.logger.debug " "
          
          applicator.list_env.map.collect do |var|
            Greased.logger.debug "   #{var}"
          end
          
          Greased.logger.debug " "
          Greased.logger.debug "#####################################################################"
          Greased.logger.debug " "
        end
        
      end
      
    end
  end
end