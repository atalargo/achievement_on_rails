achievement_on_rails
====================

Achievements Engine for Rails

This plugin require ActiveRecord and Mongoid to work

To install it, in your Gemfile add :

* If you use rubygems :

> gem 'achievement_on_rails'

* If you want use git :

> gem 'achievement_on_rails', :git => 'git://github.com:atalargo/achievement_on_rails.git'


After this, launch in your rails app root directory :

> rake achiever_engine
> rake db:migrate

You must provide a sql host configuration and a mongoid host configuration

