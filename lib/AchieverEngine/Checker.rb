
module AchieverEngine
    class Checker

        def initialize(in_progress, data)
            @in_progress_achievements = in_progress_achievements
            @in_progress_achievements[:in_progress_data] = self.reorder_mg_achievements(@in_progress_achievements[:in_progress_data])

            @data = data
        end

        def check()
            in_progress_achievements_check
            available_achievements_check
        end

        protected

        protected
        def reorder_mg_achievements(mg_collection)
            reorder = {}
            mg_collection.each do |doc|
                reorder[doc.achievement_id] = doc
            end
            reorder
        end

        def in_progress_achievements_check
            @in_progress_achievements[:achievements].each do |achievement|
                @data.each do |input_data|

                    if input_data[:type] == achievement.on_type && achievement.behaviour_type = 'badge'

                        in_progress = @in_progress_achievements[:in_progress_data][achievement.id]

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

        def available_achievements_check

            user_achievements = UserAchievement.by_project(project_id).by_user(user_id).find_or_create_by(:project_id => project_id, :user_id => user_id)

            available_achievements = AchieverEngine::Search.achievements_for(:project => project_id, :user => user_id, :mode => AchieverEngine::Search::ACHIEVEMENT_AVAILABLE_MODE)

            # p available_achievements

            available_achievements.each do |achievement|

                next if @in_progress_achievements[:in_progress_data].has_key? achievement.id

                @data.each do |input_data|
                    if input_data[:type] == achievement.on_type && achievement.behaviour_type == 'badge'
                        if input_data[:incr] >= achievement.value
                            # obtained achievement
                            new_ach = UserObtainedAchievement.new
                            new_ach.achievement_id = achievement.id
                            user_achievements.obtained << new_ach
                            #                         user_achievements.save

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
                        end
                        user_achievements.save
                    end
                end
            end

        end

    end
end
