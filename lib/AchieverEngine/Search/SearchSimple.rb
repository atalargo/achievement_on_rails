module AchieverEngine

    module Search

        class SearchSimple
            def initialize(options)
                @project_id  = (options[:project].is_a?(Numeric) ? options[:project] : options[:project].id)

                @achievements = Achievement.by_project(project_id).
                                    active.
                                    typed(options[:type]) #.all_less(obtained_user_achs.map(&:achievement_id) + in_progress_user_achs.map(&:achievement_id)) #.includes(:parents, :children)

                @achievementRelations = AchievementRelation.by_project(project_id)

                @obtained_user_achs = AchieverEngine::Obtained.get_for_user_and_achievements(options, achievements)
                @in_progress_user_achs = AchieverEngine::InProgress.get_for_user_and_achievements(options, achievements)
            end

            def search
                obtainable_ids = []
                reject_ids = []
                obtained = Hash[@obtained_user_achs.map(&:achievement_id).collect{|v| [v, true]}.flatten]

                @achievementRelations.each do |ach|
                    if !obtained.has_key?( ach.achievement_id)
                        if obtained.has_key?( ach.parent_id)
                            #     print " true/true PAs dans obt? sub.achievement_id #{!obtainable_ids.include? ach.achievement_id} #{(!obtainable_ids.include?( ach.achievement_id) ? " push " : " reject ")}\n"
                            if !obtainable_ids.include? ach.achievement_id
                                obtainable_ids.push ach.achievement_id
                            else
                                reject_ids.push ach.achievement_id
                            end
                        else
                            #             print "Reject ach, #{ach.parent.parents.count} #{!@obtained.has_key?(ach.parent_id)} Push parent \n"
                            if !obtained.has_key?(ach.parent_id) && !reject_ids.include?( ach.parent_id) &&  !obtainable_ids.include? ach.parent_id #ach.parent.parents.count == 0
                                obtainable_ids.push ach.parent_id
                            end
                            reject_ids.push ach.achievement_id
                        end
                    end
                end

                obtainable_ids = obtainable_ids + (@achievements.map(&:id) - reject_ids - obtained.keys)

                print "Final available : #{obtainable_ids.uniq!}\n"

                Achievement.by_project(project_id).
                    active.
                    typed(options[:type]).
                    where(Achievement.arel_table[:id].in(obtainable_ids)) #.includes(:parents, :children)

            end
        end

    end

end
