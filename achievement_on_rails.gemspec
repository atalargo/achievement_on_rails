$:.push File.dirname(__FILE__)+'/lib/'

require "AchieverEngine/Version"

Gem::Specification.new do |s|
	s.name = %q{achievement_on_rails}
    s.version = AchieverEngine::VERSION
	s.author = "Florent Ruard-Dumaine"
    s.homepage    = 'https://github.com/atalargo/achievement_on_rails'
    s.summary = 'Achievements Engine for Rails'
    s.description =%q{}
    s.files         = `git ls-files`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

    s.add_runtime_dependency "active_record", '>= 3.0.0'
    s.add_runtime_dependency "mongoid" >= '3.0.0'

end

