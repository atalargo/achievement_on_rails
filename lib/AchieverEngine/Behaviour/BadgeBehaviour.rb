module AchieverEngine
    module Behaviour
        class BadgeBehaviour < AchieverEngine::Behaviour::Abstract
            typing :badge

            def check(achievement, input_data)
                return_data = {}

                if input_data[:incr] >= achievement.value
                    # obtained achievement
                    new_ach = UserObtainedAchievement.new
                    new_ach.achievement_id = achievement.id
                    return_data[:obtained] = new_ach
#                     user_achievements.obtained << new_ach
#                     #                         user_achievements.save

#                     new_available_achievements = AchieverEngine::Search.achievements_for(
#                         :project            => project_id,
#                         :user               => user_id,
#                         :clean_achievements => available_achievements,
#                         :user_obtained      => user_achievements.obtained,
#                         :mode               => AchieverEngine::Search::ACHIEVEMENT_AVAILABLE_MODE
#                     )
#
#                     available_achievements.merge new_available_achievements # push new available achievements for the test
#
#                     #callback it
#                     Rails.logger.debug("Achievement obtained on project ##{project_id} for user ##{user_id} : ##{achievement.id} - #{achievement.name}")
#

                else
                    return_data[:in_progress] = UserInProgressAchievement.new(achievement_id: achievement.id, progress: input_data[:incr])
#                     user_achievements.in_progress.new(achievement_id: achievement.id, progress: input_data[:incr])
                end

                return_data
            end
        end
    end
end
