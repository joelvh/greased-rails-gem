require 'greased-rails'

namespace :greased do
  namespace :env do
    task :dump => :environment do
      options   = Greased::Options.find(Rails.root)
      applicator  = Greased::Applicator.new(Rails.application, options)
      
      Greased.logger.debug ""
      Greased.logger.debug "## GREASED [#{applicator.env.upcase}] #{'#' * (55 - applicator.env.size)}"
      Greased.logger.debug "#                                                                   #"
      Greased.logger.debug "#            ... dumping variables to *.env files ...               #"
      Greased.logger.debug "#                                                                   #"
      Greased.logger.debug "#####################################################################"
      Greased.logger.debug ""
      
      environments  = ["development", "staging", "production"]
      longest       = environments.map(&:size).max
      
      environments.each do |env|
        path      = applicator.save_env_file(Rails.root, env)
        filename  = File.basename(path)
        
        Greased.logger.debug "   [#{env}]#{' ' * (longest - env.size)} filename: #{path}"
      end
      
      Greased.logger.debug ""
      Greased.logger.debug "#####################################################################"
      Greased.logger.debug ""
      
    end
  end
  
  namespace :heroku do
    task :deploy, [:env] => [:environment] do |t, args|
      
    end
  end
end