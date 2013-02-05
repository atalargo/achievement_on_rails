module AchieverEngine
    module InProgress
        def self.get_for_user_and_achievements(options, achievements = nil)
            if options.is_a? UserAchievement
                return options.in_progress
            else
                UserAchievement.by_user(options[:user_id]).
                    by_project(options[:project_id]).first.
                    in_progress
            end
        end

    end
end
