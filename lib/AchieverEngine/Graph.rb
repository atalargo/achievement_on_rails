# require 'rgl/adjacency'
# require 'rgl/condensation'
# require 'rgl/topsort'

module AchieverEngine
    module Graph
        include AchieverEngine::Utils

#         def self.create_directed_graph(achievements)
#             dg = RGL::DirectedAdjacencyGraph[]
#             achievements.each do |ach|
#                 dg.add_vertex ach
#                 ach.children.each do |child|
#                     dg.add_edge ach,child
#                 end
#             end
#             dg.vertices.each do |v|
#                 p v
#                 p v[:id]
#             end
#             dg
#         end

        def self.create_nanoc_directed_graph(achievements)
            graph = Utils::DirectedGraph.new(achievements)
            achievements.each do |ach|
                graph.add_vertex ach
                p ach.children
                ach.children.each do |child|
                    graph.add_edge ach,child
                end
            end
            graph
        end
    end
end
