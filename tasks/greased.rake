require 'greased-rails'

namespace :greased do
  namespace :env do
    task :dump => :environment do
      options   = Greased::Applicator.rails_options
      settings  = Greased::Applicator.new(options)
      
      puts ""
      puts "############################## GREASED ##############################"
      puts "#                                                                   #"
      puts "#            ... dumping variables to *.env files ...               #"
      puts "#                                                                   #"
      puts "#####################################################################"
      puts ""
      
      environments  = ["development", "staging", "production"]
      longest       = environments.map(&:size).max
      
      environments.each do |env|
        path      = settings.save_env_file(env)
        filename  = Pathname.new(path).basename
        
        puts "   [#{env}]#{' ' * (longest - env.size)} filename: #{path}"
      end
      
      puts ""
      puts "#####################################################################"
      puts ""
      
    end
  end
  
  namespace :heroku do
    task :deploy, [:env] => [:environment] do |t, args|
      
    end
  end
end