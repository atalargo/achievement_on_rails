
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
        in_progress_achievements[:in_progress_data] = self.reorder_mg_achievements(in_progress_achievements[:in_progress_data])

#         p in_progress_achievements

        self.in_progress_achievements_check(in_progress_achievements, data)

# p in_progress_achievements[:in_progress_data]

        self.available_achievements_check(in_progress_achievements, data)
    end

    protected
    def self.reorder_mg_achievements(mg_collection)
        reorder = {}
        mg_collection.each do |doc|
            reorder[doc.achievement_id] = doc
        end
        reorder
    end

    def self.in_progress_achievements_check(in_progress_achievements, data)
        in_progress_achievements[:achievements].each do |achievement|
            data.each do |input_data|

                if input_data[:type] == achievement.on_type && achievement.behaviour_type = 'badge'

                    in_progress = in_progress_achievements[:in_progress_data][achievement.id]

                    if input_data[:incr] + in_progress.progress >= achievement.value
                        # validate achievement
                        new_ach = UserObtainedAchievement.new
                        new_ach.achievement_id = achievement.id
                        in_progress.user_achievement.obtained << new_ach
                        in_progress.destroy
                        in_progress.user_achievement.save

                        #callback obtained achievement
                        Rails.logger.debug("Achievement obtained on project ##{project_id} for user ##{user_id} : ##{achievement.id} - #{achievement.name}")
                    else
                        in_progress.inc(:progress, input_data[:incr])
                    end
                end
            end
        end
    end

    def self.available_achievements_check(in_progress_achievements, data)

        user_achievements = UserAchievement.by_project(project_id).by_user(user_id).find_or_create_by(:project_id => project_id, :user_id => user_id)

        available_achievements = AchieverEngine::Search.achievements_for(:project => project_id, :user => user_id, :mode => AchieverEngine::Search::ACHIEVEMENT_AVAILABLE_MODE)

        # p available_achievements

        available_achievements.each do |achievement|

            next if in_progress_achievements[:in_progress_data].has_key? achievement.id

            data.each do |input_data|
                if input_data[:type] == achievement.on_type && achievement.behaviour_type == 'badge'
                    if input_data[:incr] >= achievement.value
                        # obtained achievement
                        new_ach = UserObtainedAchievement.new
                        new_ach.achievement_id = achievement.id
                        user_achievements.obtained << new_ach
                        user_achievements.save

                        new_available_achievements = AchieverEngine::Search.achievements_for(
                            :project            => project_id,
                            :user               => user_id,
                            :clean_achievements => available_achievements,
                            :user_obtained      => user_achievements.obtained,
                            :mode               => AchieverEngine::Search::ACHIEVEMENT_AVAILABLE_MODE
                        )

                        available_achievements.merge new_available_achievements # push new available achievements for the test

                        #callback it
                        Rails.logger.debug("Achievement obtained on project ##{project_id} for user ##{user_id} : ##{achievement.id} - #{achievement.name}")


                    else
                        user_achievements.in_progress.new(achievement_id: achievement.id, progress: input_data[:incr])
                        user_achievements.save
                    end
                end
            end
        end

    end

end
