#require 'greased-rails'
require 'rails'

module Greased
  module Rails
    class Engine < ::Rails::Engine
      
      Greased.logger.level = Logger::DEBUG if ::Rails.env.development?
      
      rake_tasks do
        path = Pathname.new(File.join(File.dirname(__FILE__), '../../../tasks/')).realpath
        
        Dir["#{path}/*.rake"].each do |filename|
          load filename
        end
      end
      
      #http://guides.rubyonrails.org/configuring.html
      #before_configuration
      #before_initialize - before initialization
      #to_prepare - after railties and application initializers, before eager loading and middleware (on each request in dev)
      #before_eager_load - default behavior in production
      #after_initialize - after application initializes - BEFORE application initializers
      
      #app.config.before_configuration
      #:load_environment_hook
      config.before_configuration do |application|
        
        options     = Options.find(::Rails.root)
        applicator  = Applicator.new(application, options)
        variables   = applicator.variables.except("RACK_ENV", "RAILS_ENV")
        
        variables.each do |key, value|
          ENV[key.to_s] = value.to_s
        end
        
        if ::Rails.env.development?
          
          Greased.logger.debug " "
          Greased.logger.debug "## GREASED [#{applicator.env.upcase}] #{'#' * (55 - applicator.env.size)}"
          Greased.logger.debug "#                                                                   #"
          Greased.logger.debug "#                      ... loaded options ...                       #"
          Greased.logger.debug "#                                                                   #"
          Greased.logger.debug "#####################################################################"
          Greased.logger.debug " "
          
          pp options
          
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
      
      # config.before_configuration {|app| Greased.logger.debug "BEFORE CONFIGURATION"}
#       
      # config.before_initialize {|app| Greased.logger.debug "BEFORE INITIALIZE"}
#       
      # config.to_prepare {|app| Greased.logger.debug "TO PREPARE"}
#       
      # config.before_eager_load {|app| Greased.logger.debug "BEFORE EAGER LOAD"}
#       
      # config.after_initialize {|app| Greased.logger.debug "AFTER INITIALIZE"}
#       
      # hooks = [
        # :load_environment_hook, :load_active_support, :preload_frameworks, :initialize_logger, :initialize_cache, :set_clear_dependencies_hook,
        # :initialize_dependency_mechanism, :bootstrap_hook, "i18n.callbacks", :set_load_path, :set_autoload_paths, :add_routing_paths,
        # :add_locales, :add_view_paths, :load_environment_config, :append_asset_paths, :prepend_helpers_path, :load_config_initializers,
        # :engines_blank_point, :add_generator_templates, :ensure_autoload_once_paths_as_subset, :add_to_prepare_blocks, :add_builtin_route,
        # :build_middleware_stack, :eager_load!, :finisher_hook, :set_routes_reloader, :disable_dependency_loading
      # ]
#       
      # hooks.each do |hook_name|
        # initializer("greased.before.#{hook_name}", :before => hook_name, :group => :all) {|a| Greased.logger.debug "BEFORE #{hook_name}".upcase}
      # end
      
      # RUNS BEFORE ENVIRONMENT CONFIGS ARE LOADED!
      #app.config.before_initialize
      config.before_configuration do |application|
        
        options     = Options.find(::Rails.root)
        applicator  = Applicator.new(application, options)
        
        applicator.settings.apply!
        
        if ::Rails.env.development?
          Greased.logger.debug " "
          Greased.logger.debug "## GREASED [#{applicator.env.upcase}] #{'#' * (55 - applicator.env.size)}"
          Greased.logger.debug "#                                                                   #"
          Greased.logger.debug "#               ... loading application settings ...                #"
          Greased.logger.debug "#                                                                   #"
          Greased.logger.debug "#####################################################################"
          Greased.logger.debug " "
          
          applicator.settings.list.map(&:strip).map{|setting| setting.split("\n")}.flatten.each do |line|
            Greased.logger.debug "   #{line}"
          end
          
          Greased.logger.debug " "
          Greased.logger.debug "#####################################################################"
          Greased.logger.debug " "
        end
        
      end
    end
  end
end