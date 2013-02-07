
module AchieverEngine
    module Utils
        autoload :Nanoc, 'AchieverEngine/Utils/Nanoc/DirectedGraph'

        class DirectedGraph < AchieverEngine::Utils::Nanoc::DirectedGraph


=begin
        @return [boolean] true if cycle found, false is all ok
=end
            def check_cyclic_for_egde(edge)
                !successors_of(new_edge.achievement).index(new_edge.parent).nil?
            end


=begin
        @return [boolean] true if cycle found, false is all ok
=end
            def check_cyclic_for_vertex(vertex)
                return false if @roots.include? vertex

                !get_cyclic_for_vertex.empty?
            end

=begin
        @return [Array] Return array of all vertices which are in a cyclic path of the given vertex
=end
            def get_cyclic_for_vertex(vertex)
                return [] if @roots.include? vertex

                successors_of(vertex) & predecessors_of(vertex)
            end

            def get_cyclic_for_edge(edge)
                successors_of(new_edge.achievement)
            end

            def get_cyclic_path_for_vertex(vertex)
                cyclic_vertices = get_cyclic_for_vertex(vertex)
                return [] if cyclic_vertices.empty?
                # rebuild different paths
                visited = []
                paths = []
                p cyclic_vertices
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
                p vertex.id
                local_path << vertex
                direct_successors_of(vertex).each do |child|
                    if !visited.include? child
                        if cyclic_vertices.include? child
                            if parent == child
                                break
                            else
                                p "sub"
#                                 local_path << child
                                subs = get_sub_for_cycle_path(parent, child, visited, cyclic_vertices)
                                local_path << subs if !subs.empty?
                            end
                        end
                    end
                end
                local_path
            end

            def get_dfs(vertex, visited)

            end

            def check_cyclic
            end


=begin
    @return [boolean] true if cycle found, false is all ok
=end
            def check_cyclic_for_new_edge(new_edge)
                !successors_of(new_edge.achievement).index(new_edge.parent).nil?
            end
        end

        def self.filter_options(options)

            project_id  = (options[:project].is_a?(Numeric) ? options[:project] : options[:project].id)
            user_id     = (options[:user].is_a?(Numeric) ? options[:user] : options[:user].id)

        end
    end
end
