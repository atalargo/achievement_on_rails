
require 'active_support'
require 'active_support/test_case'

require 'active_record'
require 'active_record/fixtures'
require 'active_record/test_case'

class ActiveSupport::TestCase
    include ActiveRecord::TestFixtures

    @@achievements = nil
    @@achievement_relations = nil

    setup do
        ActiveRecord::IdentityMap.clear
        connect_sql_db_test
    end

    def setup
        connect_sql_db_test
        super
    end


    protected
    def achievements(d = nil)
        if @@achievements.nil?
            @@achievements = YAML.load(File.open('test/fixtures/achievements.yml'))
        end
        if d
            @@achievements[d]
        else
            @@achievements
        end
    end
    def achievement_relations(d = nil)
        if @@achievement_relations.nil?
            @@achievement_relations = YAML.load(File.open('test/fixtures/achievement_relations.yml'))
        end
        if d
            @@achievement_relations[d]
        else
            @@achievement_relations
        end
    end

end
# ActiveSupport::TestCase.fixture_path = "#{File.dirname(__FILE__)}/fixtures/"
# ActiveSupport::TestCase.fixtures :all


def create_fixtures(*table_names, &block)
    Fixtures.create_fixtures(ActiveSupport::TestCase.fixture_path, table_names, {}, &block)
end
