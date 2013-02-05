module AchieverEngine
    module Validated
        def self.get_for_user_and_achievements(options, achievements = nil)
#             UserObtainedAchievement.by_user(options[:user_id]).
#                 by_achievements(achievements).
#                 by_project(options[:project_id])
            UserAchievement.by_project(options[:project_id]).by_user(options[:user_id]).first.obtained
        end
    end
end