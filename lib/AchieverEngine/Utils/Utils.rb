
module AchieverEngine
    module Utils
        autoload :Nanoc, 'AchieverEngine/Utils/Nanoc/DirectedGraph'

        require 'AchieverEngine/Utils/AchievementGraphException'

        class DirectedGraph < AchieverEngine::Utils::Nanoc::DirectedGraph



=begin
    Suppress edge in Graph (like delete_edge) AND delete relation in Database directly


    @param [mixed] Achievement from vertex OR Edge itself (AchievementRelation instance)
    @param [mixed] Achievement to vertex OR nil

    @return [void if edge in graph AND relation in DB are deleted return true, false in other case
=end
            def delete_edge!(from_or_edge, to = nil)
                if (to == nil && from_or_edge.respond_to?( :achievement))
                    to = from_or_edge.achievement
                    from_or_edge = from_or_edge.parent
                end

                # delete in graph
                delete_edge(from_or_edge, to)

                # delete in DB
                if !from.children.delete(to)
                    # in reason of failed reltion deleting in DB, re add the edge in the graph
                    add_edge(from_or_edge, to)
                    false
                else
                    true
                end
            end

=begin
    @param [AchievementRelation]

    @return [boolean] true if cycle found, false is all ok
=end
            def check_cyclic_for_egde(edge)
                !successors_of(edge.achievement).index(edge.parent).nil?
            end

=begin
    @param [Achievement]

    @return [boolean] true if cycle found, false is all ok
=end
            def check_cyclic_for_vertex(vertex)
                return false if @roots.include? vertex

                !get_cyclic_for_vertex(vertex).empty?
            end
=begin
    @param[AchievementRelation]

    @return [boolean] true if superflous edge
=end
            def check_superfluous_edge(edge)
                !get_superflous_edge(edge).empty?
            end

=begin
    @param [Achievement]

    @return [Array] Return array of all vertices which are in a cyclic path of the given vertex
=end
            def get_cyclic_for_vertex(vertex)
                return [] if @roots.include? vertex

                successors_of(vertex) & predecessors_of(vertex)
            end

=begin
    @param [Achievement]

    @return [Array] Return array of all vertices which are in an already existant path between the 2 vertices of the edges
=end
            def get_superflous_edge(edge)
                # si le nouvel enfant n'est pas déjà dans tout les enfants quelque soit la profondeur du parent, renvoyé directement []
                return [] if (!successors_of(edge.parent).include?(edge.achievement))

                recursive_direct_successors(edge.parent, edge.achievement, [edge.achievement])
            end
=begin
    @param [AchievementRelation]

    @return [Array] Return array of all vertices which are in a cyclic path of the given edge

    TODO écrire un code qui serve à qq chose
=end
            def get_cyclic_for_edge(edge)
                successors_of(edge.achievement)
            end

            def get_cyclic_path_for_vertex(vertex)
                cyclic_vertices = get_cyclic_for_vertex(vertex)
                return [] if cyclic_vertices.empty?
                # rebuild different paths
                visited = []
                paths = []
#                 p cyclic_vertices
                direct_successors_of(vertex).each do |child|
                    if cyclic_vertices.include? child
                        paths << get_sub_for_cycle_path(vertex, child, visited, cyclic_vertices)
                    end
                end
                paths
            end

            def get_sub_for_cycle_path(parent, vertex, visited, cyclic_vertices)
                local_path = []
                visited << vertex
#                 p vertex.id
                local_path << vertex
                direct_successors_of(vertex).each do |child|
                    if !visited.include? child
                        if cyclic_vertices.include? child
                            if parent == child
                                break
                            else
#                                 p "sub"
#                                 local_path << child
                                subs = get_sub_for_cycle_path(parent, child, visited, cyclic_vertices)
                                local_path << subs if !subs.empty?
                            end
                        end
                    end
                end
                local_path
            end

=begin
    @return [Array] Return array of all vertices which are in all cyclic path in the all graph

    TODO
=end
            def check_cyclic
            end

            private
            def recursive_direct_successors(from, to, path)
                direct_successors_of(from).each do |suc|
                    if suc == to
                        return path << from
                    else
                        path_priv = recursive_direct_successors(suc, to, path)
                        if !path_priv.empty?
                            return path << from
                        end
                    end
                end
                path
            end

=begin
    @return [boolean] true if cycle found, false is all ok
=end
#             def check_cyclic_for_new_edge(new_edge)
#                 !successors_of(new_edge.achievement).index(new_edge.parent).nil?
#             end
        end

        def self.filter_options(options)

            user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)

        end

    end
end
