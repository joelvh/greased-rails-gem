require 'delegate'
require 'pathname'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/keys'

module Greased
  class Options
    
    # settings applied to application environment
    APP_SETTINGS_FILENAME_BASE  = "settings.yml"
    APP_SETTINGS_FILENAME       = "greased_#{APP_SETTINGS_FILENAME_BASE}"
    # additional settings applied to application environment 
    # after default Greased (template) settings are applied 
    # or custom settings file is applied.
    APP_PATCH_FILENAME_BASE     = "partial.yml"
    APP_PATCH_FILENAME          = "greased_#{APP_PATCH_FILENAME_BASE}"
    # environment variables to load into ENV
    ENV_VARS_FILENAME_BASE      = "variables.yml"
    ENV_VARS_FILENAME           = "greased_#{ENV_VARS_FILENAME_BASE}"
    # options to load from YAML
    OPTIONS_FILENAME            = "greased.yml"
    DEFAULT_OPTIONS_FILE        = Greased.file_path(File.dirname(__FILE__), '..', '..', 'templates', OPTIONS_FILENAME)
    # default Greased template with application settings
    DEFAULT_SETTINGS_FILE       = Greased.file_path(File.dirname(__FILE__), '..', '..', 'templates', APP_SETTINGS_FILENAME)
    DEFAULT_ENV                 = "development"
    
    class << self
      
      def defaults
        load_options(DEFAULT_OPTIONS_FILE).deep_merge!(:app_filename => DEFAULT_SETTINGS_FILE)
      end
      
      def find(path)
        #Greased.logger.debug "Find application options in: #{path}"
        
        options = defaults
        
        if Dir.exists? path
          # load rails defaults
          options = merge_options options, {
            #:env => ::Rails.env || DEFAULT_ENV,
            #:groups => ["application"],
            :app_filename => [
              Greased.file_path(path, APP_SETTINGS_FILENAME), 
              Greased.file_path(path, "greased", APP_SETTINGS_FILENAME_BASE),
              Greased.file_path(path, "config", APP_SETTINGS_FILENAME), 
              Greased.file_path(path, "config", "greased", APP_SETTINGS_FILENAME_BASE),
              DEFAULT_SETTINGS_FILE
            ],
            :partial_filename => [
              Greased.file_path(path, APP_PATCH_FILENAME), 
              Greased.file_path(path, "greased", APP_PATCH_FILENAME_BASE),
              Greased.file_path(path, "config", APP_PATCH_FILENAME), 
              Greased.file_path(path, "config", "greased", APP_PATCH_FILENAME_BASE)
            ],
            :env_filename => [
              Greased.file_path(path, ENV_VARS_FILENAME),
              Greased.file_path(path, "greased", ENV_VARS_FILENAME_BASE),
              Greased.file_path(path, "config", ENV_VARS_FILENAME),
              Greased.file_path(path, "config", "greased", ENV_VARS_FILENAME_BASE)
            ]
          },
          # load custom options
          load_options([
            Greased.file_path(path, OPTIONS_FILENAME), 
            Greased.file_path(path, "greased", OPTIONS_FILENAME),
            Greased.file_path(path, "config", OPTIONS_FILENAME), 
            Greased.file_path(path, "config", "greased", OPTIONS_FILENAME)
          ])
        end
        
        options
      end
      
      protected
      
      def load_options(filename)
        #Greased.logger.debug "Loading options from: #{filename}"
        
        merge_options Greased.load_yaml(filename)
      end
      
      def merge_options(*options)
        options.inject({}) do |all, one|
          all.deep_merge deep_symbolize_keys(one)
        end
      end
      
      private
      
      def deep_symbolize_keys(object)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), result|
            result[key.to_sym] = deep_symbolize_keys(value)
          end
        when Array
          object.map {|e| deep_symbolize_keys(e) }
        else
          object
        end
      end
      
    end
  end
end