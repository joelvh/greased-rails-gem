# Greased Rails [![Dependency Status](https://gemnasium.com/joelvh/greased-rails.png)](https://gemnasium.com/joelvh/greased-rails)

Reusable default application settings, environment variables, and deployment tasks.

Replicate common Rails application settings and environment variables using templates. Handy deployment tasks make managing your environments easier.

## Installation

Add this line to your application's Gemfile:

    gem 'greased-rails'

To automatically load environment variables and settings, require the the railties:

    gem 'greased-rails', require: %w{greased/rails/variables greased/rails/settings}

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install greased-rails

## Usage

There are four OPTIONAL configuration files you can create:

 * greased.yml (options for applying settings to environment)
 * greased_settings.yml (serialized application settings)
 * greased_partial.yml (serialized application settings that override greased_settings.yml)
 * greased_variables.yml (serialized ENV variables)

All YAML files support ERB. You can see what they look like in the "templates" folder.

### Options - greased.yml

This is a YAML serialization of options defining environment and where files are located.

If you don't create your own file, Greased will use the file in the "templates" folder of this gem. To specify your own settings, save your file to one of the following locations:

    * greased.yml (in the root of your Rails application)
    * greased/greased.yml
    * config/greased.yml
    * config/greased/greased.yml

### Application Settings - greased_settings.yml

This is a YAML serialization of most settings that you would find in "config/application.rb" and "config/environments/*.rb". What's nice is that you can easily view settings for each environment in one file and allow them to inherit from eachother.

If you don't create your own file, Greased will use the file in the "templates" folder of this gem. To specify your own settings, save your file to one of the following locations:

    * greased_settings.yml (in the root of your Rails application)
    * greased/settings.yml
    * config/greased_settings.yml
    * config/greased/settings.yml

#### Partial Settings - greased_partial.yml

This is a YAML serialization of settings you want to override in greased_settings.yml. This is useful if you let Greased load the default template and only want to override a few settings without copying the whole template file over.

Save your file to one of the following locations:

    * greased_partial.yml (in the root of your Rails application)
    * greased/partial.yml
    * config/greased_partial.yml
    * config/greased/partial.yml

### Environment Variables - greased_variables.yml

This is a YAML serialization of your environment variables. You can easily share environment variables across environments.

If you don't create your own file, Greased won't load any environment variables. To specify your own settings, save your file to one of the following locations:

    * greased_variables.yml (in the root of your Rails application)
    * greased/variables.yml
    * config/greased_variables.yml
    * config/greased/variables.yml

You can use the "greased:env:dump" Rake task to create *.env files for "development", "staging", and "production". These files can be used by Foreman to load environment variables when you start your Rails server.

(Read more about Foreman and environment variables: http://joelvanhorn.com/2012/06/12/developing-apps-with-environment-variables/)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
