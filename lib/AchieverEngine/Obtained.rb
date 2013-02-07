module AchieverEngine
    module Obtained
        def self.get_for_user_and_achievements(options, achievements = nil)

            project_id  = (options[:project].is_a?(Numeric) ? options[:project] : options[:project].id)
            user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)

            UserAchievement.by_project(project_id).by_user(user_id).first.obtained
        end
    end
end