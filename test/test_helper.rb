

require 'rake/testtask'


require './test/support_test'



desc "Run Unit tests"
task :units do
    Rake.application.invoke_task :'db:migrate'

    Rake::TestTask.new('test_units') do |t|
        print "Test units\n"
        require './test/db_ar_helper'
        t.libs << 'test/unit' << 'test' << 'unit'
        t.test_files = Dir.glob('test/unit/test_*.rb')
        t.verbose = VERBOSE
    end
    Rake.application.invoke_task :test_units

    File.delete('./test/test.sqlite')
end


desc "Run all tests (default)"
task :tests do
    Rake.application.invoke_task :units
end



