Dir.glob(File.join(File.dirname(__FILE__)+'/../lib/AchieverEngine/models', '*.rb')).each {|mod| require mod}


require File.dirname(__FILE__)+'/support_test.rb'
require File.dirname(__FILE__)+'/db_ar_helper.rb'

