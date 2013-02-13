module AchieverEngine
    module Models
        def act_as_achievable
            class_eval do
                def achievement
                    UserAchievement.by_user(id).first
                end

                def achievements
                    UserAchievement.by_user(id).first.all_achievements
                end
            end
        end
    end

end
