
# require File.dirname(File.expand_path(__FILE__))+'/../app/models/achievement'
# require File.dirname(File.expand_path(__FILE__))+'/../app/models/achievement_relation'
# require File.dirname(File.expand_path(__FILE__))+'/../app/models/user_achievement'
# require File.dirname(File.expand_path(__FILE__))+'/../app/models/user_in_progress_achievement'
# require File.dirname(File.expand_path(__FILE__))+'/../app/models/user_obtained_achievement'

autoload :Achievement,                  'AchieverEngine/models/achievement'
autoload :AchievementRelation,          'AchieverEngine/models/achievement_relation'
autoload :UserAchievement,              'AchieverEngine/models/user_achievement'
autoload :UserInProgressAchievement,    'AchieverEngine/models/user_in_progress_achievement'
autoload :UserObtainedAchievement,      'AchieverEngine/models/user_obtained_achievement'

module AchieverEngine
    autoload :Checker,      'AchieverEngine/Checker'
    autoload :Config,       'AchieverEngine/Config'
    autoload :Behaviour,    'AchieverEngine/Behaviour'
    autoload :Utils,        'AchieverEngine/Utils'
    autoload :Search,       'AchieverEngine/Search'
    autoload :InProgress,   'AchieverEngine/InProgress'
    autoload :Obtained,     'AchieverEngine/Obtained'
    autoload :Graph,        'AchieverEngine/Graph'
    autoload :VERSION,      'AchieverEngine/Version'

    def self.setup
        yield AchieverEngine::Config
        AchieverEngine::Config.parse_configuration
    end
=begin

    @group Test Achievements for an user
    @group Modify User Achievements

    @param options == {:user= > user, :project => project, :data => data)}

    @param project achievement's associated project, Object with readable id attribute, or directly a numeric value

    @param user user to test achievement, Object with id attribute, or directly a numeric value

    @param data Value(s) to test for user's achievement (available, in progress) could by array of Hash, or hash directly (Array if multiple value pass in same time)

    @return [void]
=end
    def self.hit(options, data)

        project_id  = (options[:project].is_a?(Numeric) ? options[:project] : options[:project].id)
        user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)
        data        = [data] if data.is_a? Hash

        in_progress_achievements = AchieverEngine::Search.achievements_for(:project => project_id, :user => user_id, :mode => AchieverEngine::Search::ACHIEVEMENT_IN_PROGRESS_MODE, :mongo_data => true)
# p in_progress_achievements

#         p in_progress_achievements

        AchieverEngine::Checker.new(in_progress_achievements, data).check
    end


end
