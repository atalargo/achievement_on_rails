
module AchieverEngine
    module Utils
=begin
    Exception when add a relation between achievements which will add a cyclic path in the graph of achievements
=end
        class AddCyclicGraphAchievementException < Exception

            def initialize(parent, child)
                super "You try to add a cyclic path in Achievements graph with trying to add edge between Achievement ##{parent.id} and Achievement ##{child.id}"
            end
        end

=begin
    Exception when add a relation between  an achievement and itself
=end
        class AddAutoEdgeAchievementException < Exception

            def initialize(achievement)
                super "You try to add an edge relation between an achievement (##{achievement.id}) and itself!"
            end
        end

=begin
    Exception when add a superflous relation between two achievement
=end
        class SuperflousEdgeAchievementException < Exception

            def initialize(parent, achievement)
                super "You try to add an edge relation between Achievement ##{parent.id} and Achievement ##{child.id}"
            end
        end

    end
end
