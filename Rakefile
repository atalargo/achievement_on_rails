#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('./Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

VERBOSE = (ENV['v'].nil? ? false : (ENV['v'] == '1' ? true : false ))

desc "Migrate DB"
task :'db:migrate' do |t|
    puts 'DB migrate from db/database.yml to sqlite3 test SQL db'
    require './test/db_ar_helper'

    File.delete('./test/test.sqlite') if File.exists?('./test/test.sqlite')

    connect_sql_db_test

    require "./db/migrate/create_achievements_engine"
    CreateAchievementsEngine.up
end

namespace :test do
    desc "Console IRB with require for test"
    task :console do |t|
        exec "irb -r irb/completion -r mongoid -r active_record -r ./test/console"
    end
end

require './test/test_helper.rb'


# desc "Run all tests"
task :default => :tests
