require 'active_record'
require 'logger'

require 'active_record/fixtures'
require 'active_record/test_case'

def connect_sql_db_test()
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: 'test/test.sqlite'
    ActiveRecord::Base.logger = ((ENV['v'] && ENV['v'] == '1')  ? Logger.new( STDOUT) : nil )
end
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: 'test/test.sqlite'
ActiveRecord::Base.logger = ((ENV['v'] && ENV['v'] == '1')  ? Logger.new( STDOUT) : nil )