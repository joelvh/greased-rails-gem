#require 'greased-rails'
require 'rails'

module Greased
  module Rails
    class Engine < ::Rails::Engine
      
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
        
        options     = Applicator.rails_options.merge(:app => application)
        applicator  = Applicator.new(options)
        
        applicator.variables(options).each do |key, value|
          
          # Don't mess with the environment
          next if ["RACK_ENV", "RAILS_ENV"].include?(key.to_s.upcase)
          
          ENV[key.to_s] = value.to_s
        end
        
        puts ""
        puts "############################## GREASED ##############################"
        puts "#                                                                   #"
        puts "#               ... loading application settings ...                #"
        puts "#                                                                   #"
        puts "#####################################################################"
        puts ""
        
        applicator.list_env.map.collect do |var|
          puts "   #{var}"
        end
        
        puts ""
        puts "#####################################################################"
        puts ""
        
      end
      
      # config.before_configuration {|app| puts "BEFORE CONFIGURATION"}
#       
      # config.before_initialize {|app| puts "BEFORE INITIALIZE"}
#       
      # config.to_prepare {|app| puts "TO PREPARE"}
#       
      # config.before_eager_load {|app| puts "BEFORE EAGER LOAD"}
#       
      # config.after_initialize {|app| puts "AFTER INITIALIZE"}
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
        # initializer("greased.before.#{hook_name}", :before => hook_name, :group => :all) {|a| puts "BEFORE #{hook_name}".upcase}
      # end
      
      # RUNS BEFORE ENVIRONMENT CONFIGS ARE LOADED!
      #app.config.before_initialize
      config.before_configuration do |application|
        
        options     = Applicator.rails_options.merge(:app => application)
        applicator  = Applicator.new(options)
        
        applicator.settings.apply!
        
        puts ""
        puts "############################## GREASED ##############################"
        puts "#                                                                   #"
        puts "#               ... loading application settings ...                #"
        puts "#                                                                   #"
        puts "#####################################################################"
        puts ""
        
        applicator.settings.list.map(&:strip).map{|setting| setting.split("\n")}.flatten.each do |line|
          puts "   #{line}"
        end
        
        puts ""
        puts "#####################################################################"
        puts ""
        
      end
    end
  end
end