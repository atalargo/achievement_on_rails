module AchieverEngine
    module InProgress
        def self.get_for_user_and_achievements(options, achievements = nil)

            project_id  = (options[:project].is_a?(Numeric) ? options[:project] : options[:project].id)
            user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)

            if options.is_a? UserAchievement
                return options.in_progress
            else
                UserAchievement.by_project(project_id).by_user(user_id).first.in_progress
            end
        end

    end
end
