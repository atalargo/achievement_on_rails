Gem::Specification.new do |s|
	s.name = %q{achievement_on_rails}
	s.version = '0.0.3'
	s.summary = 'Achievements Engine for Rails'
	s.author = "Florent Ruard-Dumaine"
	s.files = [
		"Gemfile",
		"app",
"app/models",
"app/models/achievement.rb",
"app/models/user_achievement.rb",
"app/models/achievement_relation.rb",
"app/models/user_in_progress_achievement.rb",
"app/models/user_obtained_achievement.rb",
"db",
"db/migrate",
"db/migrate/create_achievements_engine.rb",
"lib",
"lib/AchieverEngine.rb",
"lib/AchieverEngine",
"lib/AchieverEngine/search.rb",
"lib/AchieverEngine/Utils",
"lib/AchieverEngine/Utils/Nanoc",
"lib/AchieverEngine/Utils/Nanoc/dgraph.rb",
"lib/AchieverEngine/Utils/utils.rb",
"lib/AchieverEngine/validated.rb",
"lib/AchieverEngine/in_progress.rb",
"lib/AchieverEngine/Graph.rb"
	]
end

