#require 'greased-rails'
#require 'rails'

module Greased
  module Rails
    class Engine < ::Rails::Engine
      rake_tasks do
        Dir[File.join(File.dirname(__FILE__), '../../../tasks/*.rake')].each do |filename|
          load filename
        end
      end 
    end
  end
end