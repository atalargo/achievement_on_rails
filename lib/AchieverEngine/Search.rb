
module AchieverEngine
    module Search

        ALL_MODE                        = :all
        ACHIEVEMENT_AVAILABLE_MODE      = :available
        ACHIEVEMENT_IN_PROGRESS_MODE    = :in_progress
        ACHIEVEMENT_OBTAINED_MODE       = :obtained

        def self.get_available_for_user(options)

            Search::SimpleSearch.new(option).search

#             project_id  = (options[:project].is_a?(Numeric) ? options[:project] : options[:project].id)
#
#             achievements = Achievement.by_project(project_id).
#                 active.
#                 typed(options[:type]) #.all_less(obtained_user_achs.map(&:achievement_id) + in_progress_user_achs.map(&:achievement_id)) #.includes(:parents, :children)
#
#             achievementRelations = AchievementRelation.by_project(project_id)
#
#             obtained_user_achs = AchieverEngine::Obtained.get_for_user_and_achievements(options, achievements)
#             in_progress_user_achs = AchieverEngine::InProgress.get_for_user_and_achievements(options, achievements)
#
# #             p achievements
#
#             obtainable_ids = []
#             reject_ids = []
#             obtained = Hash[obtained_user_achs.map(&:achievement_id).collect{|v| [v, true]}.flatten]
#
#             achievementRelations.each do |ach|
#                  if !obtained.has_key?( ach.achievement_id)
#                     if obtained.has_key?( ach.parent_id)
#                         #     print " true/true PAs dans obt? sub.achievement_id #{!obtainable_ids.include? ach.achievement_id} #{(!obtainable_ids.include?( ach.achievement_id) ? " push " : " reject ")}\n"
#                         if !obtainable_ids.include? ach.achievement_id
#                             obtainable_ids.push ach.achievement_id
#                         else
#                             reject_ids.push ach.achievement_id
#                         end
#                     else
#                         #             print "Reject ach, #{ach.parent.parents.count} #{!@obtained.has_key?(ach.parent_id)} Push parent \n"
#                         if !obtained.has_key?(ach.parent_id) && !reject_ids.include?( ach.parent_id) #ach.parent.parents.count == 0 &&
#                             if !obtainable_ids.include? ach.parent_id
#                                 obtainable_ids.push ach.parent_id
#                             end
#                         end
#                         reject_ids.push ach.achievement_id
#                     end
#                 end
#             end
#
#             obtainable_ids = obtainable_ids + (achievements.map(&:id) - reject_ids - obtained.keys)
#
#             print "Final available : #{obtainable_ids.uniq!}\n"
#
#             Achievement.by_project(project_id).
#                 active.
#                 typed(options[:type]).
#                 where(Achievement.arel_table[:id].in(obtainable_ids)) #.includes(:parents, :children)
#


        end


        def self.get_available_for_user_by_nanoc(options)

            Search::SearchNanoc.new(options).search
#             project_id  = (options[:project].is_a?(Numeric) ? options[:project] : options[:project].id)
#             user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)
#
#             all_achievements = Achievement.by_project(project_id).
#                         active.
#                         typed(options[:type]).
#                         includes(:children).all
#
#             graph = AchieverEngine::Graph.create_nanoc_directed_graph(all_achievements)
#
# p options
#
#             obtained_user_achs = if options[:user_obtaineds]
#                                         options[:user_obtaineds]
#                                     else
#                                         AchieverEngine::Obtained.get_for_user_and_achievements(options, all_achievements).all
# #                                     AchieverEngine::Obtained.get_for_user_and_achievements({:project_id => project_id, :user_id => user_id}, all_achievements).all
#                                 end
#
#             obtained_ids = obtained_user_achs.map(&:achievement_id)
#
# #             in_progress_user_achs = AchieverEngine::InProgress.get_for_user_and_achievements({:project_id => project_id, :user_id => user_id}, all_achievements).all
#
#
#
#             removes = []
#
# #             p "proc"
#             pr = Proc.new {|u|
# #                            p "call proc #{u.id}"
#                 if (obtained_ids.include?(u.id))
#                     removes.push u
#                     graph.direct_successors_of(u).each do |v|
#                         pr.call(v)
#                     end
#                 else
# #                     obtainable_ids.push u
#                 end
#             }
#
# #             p "roots"
#             graph.roots.each do |u|
#                 pr.call(u)
#             end
#
#             removes.each do |u|
#                 graph.delete_edges_from(u)
#                 graph.delete_vertex(u)
#             end
#             # obtainable_ids = graph.roots.map(&:id)
#
# #             graph.roots.each do |u|
# #                 obtainable_ids.push u.id
# #                 obtainables.push u
# #             end
#
#             print "Final #{graph.roots.map(&:id)}\n"
# #             p obtainables
# #             p obtainable_ids
# #             p graph.roots.map(&:id)
#
#             graph.roots
        end



        def self.achievements_for(options, mode = nil, mongo_data = false)

            project_id  = (options[:project].is_a?(Numeric) ? options[:project] : options[:project].id)
            user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)
            mode        = (options[:mode].nil? ? ALL_MODE : options[:mode])
            mongo_data  = (options[:mongo_data].nil? ? false : true)

            user_achi = case mode
                when ACHIEVEMENT_AVAILABLE_MODE
                    availables = self.get_available_for_user_by_nanoc(:project => project_id, :user => user_id, :user_obtaineds => (options[:user_obtaineds] ? options[:user_obtaineds] : nil))

                    if options[:clean_achievements] && options[:clean_achievements].is_a?( Array ) && options[:clean_achievements][0].is_a?( Integer)
                        availables = availables.collect do |ach|
                            !options[:clean_achievements].include?(ach.achievement_id)
                        end
                    end
                    availables
                when ACHIEVEMENT_OBTAINED_MODE || ACHIEVEMENT_IN_PROGRESS_MODE

                    user_achs = ( mode == ACHIEVEMENT_OBTAINED_MODE ? AchieverEngine::Obtained : AchieverEngine::InProgress).get_for_user_and_achievements(options)

                    achs = if user_achs.size == 0
                        []
                    else
                        Achievement.active.by_project(project_id).in(user_achs.map(&:achievement_id))
                    end

                    if mongo_data
                        mongo_ret = {:achievements => achs}
                        (mode == ACHIEVEMENT_OBTAINED_MODE ? mongo_ret[:obtained] = user_achs : mongo_ret[:in_progress_data] = user_achs)
                        mongo_ret
                    else
                        achs
                    end

                else
                    lam = lambda{ |project_id, user_filtered_achs|
                        user_filtered_achs.size == 0 ? [] : Achievement.active.by_project(project_id).in(user_filtered_achs.map(&:achievement_id))
                    }

                    user_achs = UserAchievement.by_project(project_id).by_user(user_id).first
                    {
                        :obtained => (user_achs.nil? ? [] : lam.call(project_id, user_achs.obtained) ),
                        :in_progress => (user_achs.nil? ? [] : lam.call(project_id, user_achs.in_progress) )
                    }
            end
        end

        def self.achievements_filter(achievements, mapped_id)
            achievements.collect{|ach| mapped_id.include? ach.id}
        end

       

=begin

Requête pour avoir les achievements disponible par le biais de la table de relation, enfants des achievements déjà réalisé ET achievement racine non encore fait

SELECT achievement_id AS id FROM achievement_relations WHERE project_id = 4 AND parent_id IN (1,2) AND achievement_id NOT IN (1,2)
UNION
SELECT parent_id AS id FROM achievement_relations WHERE project_id = 4 AND achievement_id NOT IN (1,2) AND parent_id NOT IN (1,2);


Il faut réunir à ce résultat les achievements orphelins non encore faits

SELECT id FROM achievements WHERE project_id = 4 AND active = true AND id NOT IN (
    SELECT achievement_id AS id FROM achievement_relations WHERE project_id = 4 AND achievement_id IN (1,2,3,7,8,6,10,11,12)
    UNION
    SELECT parent_id FROM achievement_relations WHERE project_id = 4 AND parent_id IN (1,2,3,7,8,6,10,11,12)
) AND id NOT IN (1,2);


==> AR code


# =end

basic all maked in rails
ARs = AchievementRelation.by_project(4).all
Achs = Achievement.by_project(4).active.all

ach_all_ids = Achs.map(&:id)

obtained = {1 => true, 2 => true}
obtainable_ids = {}
obtainable_achs = []

ARs.each do |ach|
    if !obtained.has_key?( ach.achievement_id)
        if obtained.has_key?( ach.parent_id)
            obtainable_ids[ach.achievement_id] = true if obtainable_ids[ach.achievement_id].nil?
        else
            obtainable_ids[ach.parent_id] = true if obtainable_ids[ach.parent_id].nil?
        end
    end
end

obtainable_ids.uniq!
obtainable_achs = Achs.reject{|a| !obtainable_ids.include? a.id}

ids_to_reject = (ARs.map(&:parent_id) | ARs.map(&:achievement_id)) | obtained.keys

Achs.collect{|a| ids_by_ar}


Use SQL in rails
obtained_str = {1 => true, 2 => true}.keys.join(',')
obtainable_ids_b1 = []
obtainable_achs_b1 = []
obtainable_ids_b2 = []
obtainable_achs_b2 = []

Benchmark.bmbm do |x|
    x.report("Benchmark find_by_sql") do
       100.times do |idtime|
            achs = Achievement.by_project(4).active.all.to_a
            ach_ids = achs.map(&:id)

            obtainable_achs_b1 = Achievement.find_by_sql("SELECT * FROM achievements WHERE project_id = 4 AND active = true AND id IN (
                SELECT achievement_id AS id FROM achievement_relations WHERE project_id = 4 AND parent_id IN (#{obtained_str}) AND achievement_id NOT IN (#{obtained_str})
                UNION
                SELECT parent_id AS id FROM achievement_relations WHERE project_id = 4 AND achievement_id NOT IN (#{obtained_str}) AND parent_id NOT IN (#{obtained_str})
            )")
            obtainable_achs_b1.concat  Achievement.find_by_sql("SELECT * FROM achievements WHERE project_id = 4 AND active = true AND id NOT IN (
                SELECT achievement_id AS id FROM achievement_relations WHERE project_id = 4 AND achievement_id IN (#{ach_ids.join(',')})
                UNION
                SELECT parent_id FROM achievement_relations WHERE project_id = 4 AND parent_id IN (#{ach_ids.join(',')})
            ) AND id NOT IN (#{obtained_str})")

            obtainable_ids_b1 = obtainable_achs_b1.map(&:id)

            p "Pass #{idtime} : #{obtainable_ids_b1.join(', ')}"
       end
     end

    x.report("Benchmard connection.select_all") do
        100.times do  |idtime|
            achs = Achievement.by_project(4).active.all.to_a
            ach_ids = Achs.map(&:id)

            obtainable_achs_b2 = Achievement.connection.select_all("SELECT * FROM achievements WHERE project_id = 4 AND active = true AND id IN (
                SELECT achievement_id AS id FROM achievement_relations WHERE project_id = 4 AND parent_id IN (#{obtained_str}) AND achievement_id NOT IN (#{obtained_str})
                UNION
                SELECT parent_id AS id FROM achievement_relations WHERE project_id = 4 AND achievement_id NOT IN (#{obtained_str}) AND parent_id NOT IN (#{obtained_str})
            )")

            obtainable_achs_b2.concat  Achievement.connection.select_all("SELECT * FROM achievements WHERE project_id = 4 AND active = true AND id NOT IN (
                SELECT achievement_id AS id FROM achievement_relations WHERE project_id = 4 AND achievement_id IN (#{ach_ids.join(',')})
                UNION
                SELECT parent_id FROM achievement_relations WHERE project_id = 4 AND parent_id IN (#{ach_ids.join(',')})
            ) AND id NOT IN (#{obtained_str})")

            obtainable_ids_b2 = obtainable_achs_b2.map{|a| a["id"]}

            p "Pass #{idtime} : #{obtainable_ids_b2.join(', ')}"
       end
     end
   end
end

=end

    end
end

=begin

rejected = recupered = {}
                        dg.edges.each do |edge|
     if !rejected.has_key? edge.source.id
        if !recupered.has_key? edge.source.id
            recupered[edge.source.id] = edge.source
        end
     end
     if !rejected.has_key? edge.target.id
        rejected[edge.target.id] =true
     end
     if recupered.has_key? edge.target.id
        recupered.delete(edge.target.id)
     end
   end


=end
