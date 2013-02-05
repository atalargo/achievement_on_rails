class AchieverEngineGenerator < Rails::Generators::Base
	source_root File.expand_path("../../../", __FILE__)
	def create_initializer_file

        copy_file "config/initializers/achiver_engine.rb", "config/initializers/achiver_engine.rb"

		Dir.glob(File.join(File.expand_path("../../../db/migrate",__FILE__),"*.rb")).each do |fil|
			copy_file fil, "db/migrate/#{Time.now.strftime('%Y%m%d%H%M%S')}_"+File.basename(fil)
		end
	end
end

