
require 'cucumber'
require 'cucumber/rspec/doubles'


require 'database_cleaner'
require 'database_cleaner/cucumber'

require 'bundler/setup'

Bundler.setup(:default, :test)
Bundler.require(:default, :test)


World(FactoryGirl::Syntax::Methods)

MIGRATIONS_DIR = File.dirname(__FILE__) +'/../../../db/migrate'

ActiveRecord::Base.establish_connection(YAML.load_file(File.dirname(__FILE__) + '/database.yml')['test_achievement'])
ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate MIGRATIONS_DIR, nil

Rspec.configure do |config|

    config.include FactoryGirl::Syntax::Methods

    config.before(:suite) do
        begin
            DatabaseCleaner.start
            FactoryGirl.lint
        ensure
            DatabaseCleaner.strategy = :transaction
            DatabaseCleaner.clean_with(:truncation)
            ActiveRecord::Migrator.rollback MIGRATIONS_DIR
        end
    end

end
