require 'delegate'
require 'pathname'
require 'active_support/core_ext/hash/deep_merge'

module Greased
  class Applicator
    
    APP_SETTINGS_FILENAME_BASE  = "settings.yml"
    APP_SETTINGS_FILENAME       = "greased_#{APP_SETTINGS_FILENAME_BASE}"
    ENV_VARS_FILENAME_BASE      = "variables.yml"
    ENV_VARS_FILENAME           = "greased_#{ENV_VARS_FILENAME_BASE}"
    DEFAULT_SETTINGS_FILE       = Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'templates', APP_SETTINGS_FILENAME)).realpath
    DEFAULT_ENV                 = "development"
    
    def self.default_options
      {
        :app => nil,
        :env => ENV['RAILS_ENV'] || ENV['RACK_ENV'] || DEFAULT_ENV,
        :groups => ["application"],
        :app_filename => DEFAULT_SETTINGS_FILE,
        #:env_filename => [],
        :skip_erb => false
      }
    end
    
    def self.rails_options
      if defined? ::Rails
        default_options.merge(
          :app => ::Rails.application,
          #:env => ::Rails.env || DEFAULT_ENV,
          #:groups => ["application"],
          :app_filename => [
            File.join(::Rails.root, APP_SETTINGS_FILENAME), 
            File.join(::Rails.root, "greased", APP_SETTINGS_FILENAME_BASE),
            File.join(::Rails.root, "config", APP_SETTINGS_FILENAME), 
            File.join(::Rails.root, "config", "greased", APP_SETTINGS_FILENAME_BASE),
            DEFAULT_SETTINGS_FILE
          ],
          :env_filename => [
            File.join(::Rails.root, ENV_VARS_FILENAME),
            File.join(::Rails.root, "greased", ENV_VARS_FILENAME_BASE),
            File.join(::Rails.root, "config", ENV_VARS_FILENAME),
            File.join(::Rails.root, "config", "greased", ENV_VARS_FILENAME_BASE)
          ]
        )
      else
        default_options
      end
    end
    
    attr_accessor :app, :env, :groups
    
    def initialize(options)
      @options  = self.class.default_options.merge(options)
      @app      = @options[:app]
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
    
    def puts_env(options = {})
      puts(*list_env(options))
    end
    
    def list_env(options = {})
      variables(options).collect{|key, value| "#{key}=#{value}"}
    end
    
    def save_env_file(environment, filename = nil)
      filename ||= File.join(::Rails.root, "#{environment}.env")
      
      File.open(filename, 'w') do |file|
        list_env(:env => environment).each{|line| file.puts line }
      end
      
      filename
    end
    
    def variables(options = {})
      options             = @options.merge(options)
      groups              = Array.wrap(options[:groups])
      grouped_variables   = load_settings(@options[:env_filename])
      
      groups.inject({}) do |all, group|
        all.merge grouped_variables.fetch(options[:env], {}).fetch(group, {})
      end
    end
    
    def settings(options = {})
      options = @options.merge(options)
      config  = load_settings(options[:app_filename], options).fetch(env, {})
      Settings.new(app, env, config)
    end
    
    protected
    
    def load_settings(filename, options = {})
      # allow multiple filenames and use the first one that exists
      filename = Array.wrap(filename).find{|path| File.exists?(path)}
      
      unless filename.nil?
        source  = File.read(filename)
        source  = ERB.new(source).result unless options[:skip_erb]
        all     = YAML.load(source)
        defaults = all.delete('defaults') || {}
        
        all.each do |environment, settings|
          all[environment] = defaults.deep_merge(settings)
        end
      end
      
      all || {}
    end
    
    
  end
end