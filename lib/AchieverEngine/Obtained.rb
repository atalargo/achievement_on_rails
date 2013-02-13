module AchieverEngine
    module Obtained
        def self.get_for_user_and_achievements(options, achievements = nil)

            user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)

            ua = UserAchievement.by_user(user_id).first
            if ua
                ua.obtained
            else
                nil
            end
        end
    end
end