require File.dirname(File.expand_path(__FILE__))+'/../app/models/achievement'
require File.dirname(File.expand_path(__FILE__))+'/../app/models/achievement_relation'
require File.dirname(File.expand_path(__FILE__))+'/../app/models/user_achievement'
require File.dirname(File.expand_path(__FILE__))+'/../app/models/user_in_progress_achievement'
require File.dirname(File.expand_path(__FILE__))+'/../app/models/user_obtained_achievement'

module AchieverEngine

    autoload :Utils,        'AchieverEngine/Utils'
    autoload :Search,       'AchieverEngine/search'
    autoload :InProgress,   'AchieverEngine/in_progress'
    autoload :Validated,    'AchieverEngine/validated'
    autoload :Graph,        'AchieverEngine/Graph'

=begin
    options == {:user= > user, :project => project, :data => data)}

    data could by array of Hash, or hash directly (Array if multiple value pass in same time)
=end
    def self.hit(project, user, data)
        user_achievements = UserAchievement.by_project(project.id).by_user(user.id).find_or_create_by(:project_id => project.id, :user_id => user.id)
p user_achievements.in_progress
        in_progress_achievements = AchieverEngine::Search.achievements_for(user_achievements, 'in_progress', true)
p in_progress_achievements
        in_progress_achievements[:in_progress_data] = self.reorder_mg_achievements(in_progress_achievements[:in_progress_data])
        data = [data] if data.is_a? Hash

        p in_progress_achievements
        in_progress_achievements[:achievements].each do |achievement|
            data.each do |input_data|
                if input_data[:type] == achievement.on_type
                    if achievement.behaviour_type = 'badge'
                        in_progress = in_progress_achievements[:in_progress_data][achievement.id]

                        if input_data[:incr] + in_progress.progress >= achievement.value
                            # validate achievement
                            new_ach = UserObtainedAchievement.new
                            new_ach.achievement_id = achievement.id
                            in_progress.user_achievement.obtained << new_ach
                            in_progress.destroy
                            in_progress.user_achievement.save

                            #callback obtained achievement
                            Rails.logger.debug("Achievement obtained on project ##{project.id} for user ##{user.id} : ##{achievement.id} - #{achievement.name}")
                        else
                            in_progress.inc(:progress, input_data[:incr])
                            in_progress.save
                        end
                    end
                end
            end
        end

        available_achievements = AchieverEngine::Search.achievements_for({:project => project, :user => user}, 'available')

        available_achievements.each do |achievement|
            next if in_progress_achievements[:in_progress_data].has_key? achievement.id
            data.each do |input_data|
                if input_data[:type] == achievement.on_type
                    if achievement.behaviour_type = 'badge'
                        if input_data[:incr] >= achievement.value
                            # obtained achievement
                            new_ach = UserObtainedAchievement.new
                            new_ach.achievement_id = achievement.id
                            user_achievements.obtained << new_ach
                            user_achievements.save

                            new_available_achievements = AchieverEngine::Search.achievements_for({
                                                                                                    :project => project,
                                                                                                    :user => user,
                                                                                                    :clean_achievements => available_achievements,
                                                                                                    :user_obtained => user_achievements.obtained
                                                                                                 }, 'available')

                            available_achievements.merge new_available_achievements # push new available achievements for the test

                            #callback it
                            Rails.logger.debug("Achievement obtained on project ##{project.id} for user ##{user.id} : ##{achievement.id} - #{achievement.name}")


                        else
                            in_pro_ach = UserInProgressAchievement.new
                            in_pro_ach.achievement_id = achievement.id
                            in_pro_ach.progress = input_data[:incr]
                            user_achievements.in_progress << in_pro_ach
                            user_achievements.save
                        end
                    end
                end
            end
        end
    end

    protected
    def self.reorder_mg_achievements(mg_collection)
        reorder = {}
        mg_collection.each do |doc|
            reorder[doc.achievement_id] = doc
        end
        reorder
    end
end
