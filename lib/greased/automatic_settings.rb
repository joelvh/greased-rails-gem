require 'delegate'
require 'pathname'
require 'active_support/core_ext/hash/deep_merge'

module Greased
  class Applicator
    
    DEFAULT_ENV           = "development"
    APP_SETTINGS_FILENAME = "greased_settings.yml"
    ENV_VARS_FILENAME     = "greased_variables.yml"
    
    def self.hook!(options = rails_options)
      settings = self.new(rails_options.merge(options))
      settings.hook_env!
      settings.hook_app!
      settings
    end
    
    def self.load!(options = rails_options)
      settings = self.new(rails_options.merge(options))
      settings.load_env!
      settings.application_settings.apply!
      settings
    end
    
    def self.default_options
      {
        :app => nil,
        :env => ENV['RAILS_ENV'] || ENV['RACK_ENV'] || DEFAULT_ENV,
        :groups => ["application"],
        :app_filename => File.join(File.dirname(__FILE__), APP_SETTINGS_FILENAME),
        :env_filename => File.join(File.dirname(__FILE__), ENV_VARS_FILENAME),
        :skip_erb => false
      }
    end
    
    def self.rails_options
      if defined? Rails
        default_options.merge(
          :app => Rails.application,
          #:env => Rails.env || DEFAULT_ENV,
          #:groups => ["application"],
          :app_filename => [File.join(Rails.root, APP_SETTINGS_FILENAME), File.join(Rails.root, "config", APP_SETTINGS_FILENAME)],
          :env_filename => [File.join(Rails.root, ENV_VARS_FILENAME),     File.join(Rails.root, "config", ENV_VARS_FILENAME)]
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
    
    def hook_env!(options = {})
      # assumes Rails application
      app.config.before_configuration{ load_env!(options) }
      self
    end
    
    def load_env!(options = {})
      environment_variables(options).each{|key, value| ENV[key.to_s] = value.to_s}
      self
    end
    
    def puts_env(options = {})
      puts(*list_env(options))
    end
    
    def list_env(options = {})
      environment_variables(options).collect{|key, value| "#{key}=#{value}"}
    end
    
    def save_env_file(environment, filename = nil)
      filename ||= File.join(Rails.root, "#{environment}.env")
      
      puts "Creating #{Pathname.new(filename).basename}"
      
      File.open(filename, 'w') do |file|
        list_env(:env => environment).each{|line| file.puts line }
      end
    end
    
    def hook_app!
      app.config.before_initialize{ application_settings.apply! }
      self
    end
    
    def environment_variables(options = {})
      options             = @options.merge(options)
      groups              = Array.wrap(options[:groups])
      grouped_variables   = load_settings(@options[:env_filename])
      
      groups.inject({}) do |all, group|
        all.merge grouped_variables.fetch(options[:env], {}).fetch(group, {})
      end
    end
    
    def application_settings(options = {})
      options = @options.merge(options)
      config  = load_settings(options[:app_filename], options).fetch(env, {})
      ApplicationSettings.new(app, env, config)
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
    
    class ApplicationSettings
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
              @settings << ApplicationSetting.new(@application, target, key, value, @environment, parents)
            end
          end
        end
      end
    end
    
  end
end