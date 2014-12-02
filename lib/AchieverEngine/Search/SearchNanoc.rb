module AchieverEngine

    module Search

        class SearchNanoc
            def initialize(options)

                @project_id  = (options[:project].is_a?(Numeric) ? options[:project] : options[:project].id)
#                 @user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)

                all_achievements = Achievement.by_project(@project_id).
                    active.
                    typed(options[:type]).
                    includes(:children).all

                @graph = AchieverEngine::Graph.create_nanoc_directed_graph(all_achievements)

                p options

                obtained_user_achs = if options[:user_obtaineds]
                    options[:user_obtaineds]
                else
                    AchieverEngine::Obtained.get_for_user_and_achievements(options, all_achievements).all
                    #                                     AchieverEngine::Obtained.get_for_user_and_achievements({:project_id => project_id, :user_id => user_id}, all_achievements).all
                end

                @obtained_ids = obtained_user_achs.map(&:achievement_id)

            end

            def search

                removes = []

                #             p "proc"
                pr = Proc.new {|u|
                    #                            p "call proc #{u.id}"
                    if (@obtained_ids.include?(u.id))
                        removes.push u
                        @graph.direct_successors_of(u).each do |v|
                            pr.call(v)
                        end
#                     else
#                     #                     obtainable_ids.push u
                    end
                }

                #             p "roots"
                @graph.roots.each do |u|
                    pr.call(u)
                end

                removes.each do |u|
                    @graph.delete_edges_from(u)
                    @graph.delete_vertex(u)
                end
                # obtainable_ids = graph.roots.map(&:id)

                #             graph.roots.each do |u|
                #                 obtainable_ids.push u.id
                #                 obtainables.push u
                #             end

                print "Final #{@graph.roots.map(&:id)}\n"
                #             p obtainables
                #             p obtainable_ids
                #             p graph.roots.map(&:id)

                @graph.roots
            end

        end

    end

end
