require 'delegate'
require 'pathname'
require 'active_support/core_ext/hash/deep_merge'

module Greased
  class Applicator
    
    attr_accessor :app, :env, :groups
    
    def initialize(application, options = {})
      @options  = Options.defaults.merge(options)
      @app      = application#@options[:app]
      @env      = @options[:env]
      @groups   = @options[:groups]
    end
    
    def configure(environment = nil, &block)
      if block_given? && (environment.nil? || env == environment.to_s)
        args = []
        args << app if [-1, 1].include?(proc.arity)
        args << env if [-1, 2].include?(proc.arity)
        
        block.call(*args)
      end
      self
    end
    
    def list_env(options = {})
      variables(options).collect{|key, value| "#{key}=#{value}"}
    end
    
    def save_env_file(path, environment, filename = nil)
      filename ||= Greased.file_path(path, "#{environment}.env")
      
      File.open(filename, 'w') do |file|
        list_env(:env => environment).each{|line| file.puts line }
      end
      
      filename
    end
    
    def variables(options = {})
      options             = @options.merge(options)
      groups              = Array.wrap(options[:groups])
      grouped_variables   = load_settings(options[:env_filename])
      
      groups.inject({}) do |all, group|
        all.merge grouped_variables.fetch(options[:env], {}).fetch(group, {})
      end
    end
    
    # Apply variables to `ENV` constant.
    #
    # @param options [Hash] Options for setting `ENV` variables.
    # @option options [Boolean] :overwrite Whether to overwrite
    #   existing values in `ENV`
    # @return [Hash] Returns a list of variables that were applied
    #   (unless the variable existed and the :overwrite option
    #   was not specified)
    def apply_variables_to_environment!(options = {})
      variables_to_apply = variables.except("RACK_ENV", "RAILS_ENV")
      
      variables_to_apply.each do |key, value|
        if !ENV.has_key?(key.to_s) || options[:overwrite] == true
          ENV[key.to_s] = value.to_s
        end
      end
      
      variables_to_apply
    end
    
    def settings(options = {})
      options = @options.merge(:env => env).merge(options)
      # get settings for application environment
      config = load_settings(options[:app_filename], options).fetch(options[:env], {})
      # add partial settings for environment
      config.deep_merge! load_settings(options[:partial_filename], options).fetch(options[:env], {})
      
      Settings.new(app, env, config)
    end
    
    protected
    
    def load_settings(filename, options = {})
      all       = Greased.load_yaml(filename, options)
      defaults  = all.delete('defaults') || {}
      
      all.each do |environment, settings|
        all[environment] = defaults.deep_merge(settings)
      end
    end
    
  end
end