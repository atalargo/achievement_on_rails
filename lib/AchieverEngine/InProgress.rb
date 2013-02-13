module AchieverEngine
    module InProgress
        def self.get_for_user_and_achievements(options, achievements = nil)

            user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)

            if options.is_a? UserAchievement
                return options.in_progress
            else
                UserAchievement.by_user(user_id).first
                if ua
                    ua.in_progress
                else
                    nil
                end
            end
        end

    end
end
