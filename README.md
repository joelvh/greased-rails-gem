# Greased Rails

Reusable default application settings, environment variables, and deployment tasks.

Replicate common Rails application settings and environment variables using templates. Handy deployment tasks make managing your environments easier.

## Installation

Add this line to your application's Gemfile:

    gem 'greased-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install greased-rails

## Usage

There are two configuration files you can create (optional):

 * greased_settings.yml (serialized application settings)
 * greased_variables.yml (serialized ENV variables)

You can see what they look like in the "examples" folder.

### Application Settings - greased_settings.yml

This is a YAML serialization of most settings that you would find in "/app/config/application.rb" and "config/environments/*.rb". What's nice is that you can easily view settings for each environment in one file and allow them to inherit from eachother.

You can save your "greased_settings.yaml" file in the root of your Rails application or in the "config" folder. If you don't create your own file, Greased will use the file in the "examples" folder of this gem.

### Environment Variables - greased_variables.yml

This is a YAML serialization of your environment variables. You can easily share environment variables across environments.

You can save your "greased_settings.yaml" file in the root of your Rails application or in the "config" folder. If you don't create your own file, Greased won't load any environment variables.

You can use the "greased:env:dump" Rake task to create *.env files for "development", "staging", and "production". These files can be used by Foreman to load environment variables when you start your Rails server.

(Read more about Foreman and environment variables: http://joelvanhorn.com/2012/06/12/developing-apps-with-environment-variables/)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
