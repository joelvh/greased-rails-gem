require_relative '../automatic_settings.rb'

namespace :greased do
  namespace :env do
    task :dump => :environment do
      settings = AutomaticSettings.new(AutomaticSettings.rails_options)
      ["development", "staging", "production"].each do |env|
        settings.save_env_file(env)
      end
    end
  end
  
  namespace :heroku do
    task :deploy, [:env] => [:environment] do |t, args|
      
    end
  end
end