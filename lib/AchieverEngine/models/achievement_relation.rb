class AchievementRelation < ActiveRecord::Base

    attr_accessible :achievement_id, :parent_id, :created_at, :updated_at

    belongs_to :achievement, :class_name => 'Achievement'
    belongs_to :parent,      :class_name => 'Achievement'


    scope :by_parent,   lambda { |parent_id| where(:parent_id => parent_id) unless parent_id.nil? }
    scope :by_child,    lambda { |child_id| where(:achievement_id => child_id) unless child_id.nil? }

    before_save         :check_relation_private

    def self.all_ids(options)
        ids = []
        self.all.each do |ar|
            ids.push ar.achievement_id,ar.parent_id
        end
        ids.uniq
    end

    class << self

        #class methods

        def check_relation(parent, achievement)
            self.temp_achievement_relation(parent,achievement).check_relation
        end

        def check_cyclic(parent, achievement)
            self.temp_achievement_relation(parent,achievement).check_cyclic
        end

        def check_superfluous_edge(parent, achievement)
            self.temp_achievement_relation(parent,achievement).check_superfluous_edge
        end

        protected
        def temp_achievement_relation(parent, achievement)
            AchievementRelation.new({:parent_id => parent.id, :achievement_id => achievement.id})
        end
    end

    def check_cyclic
        @temp_graph = AchieverEngine::Graph.create_nanoc_directed_graph(Achievement.includes(:children).all)
        if @temp_graph.check_cyclic_for_egde(self)
            @temp_graph = nil
            throw AchieverEngine::Utils::AddCyclicGraphAchievementException.new(self.parent, self.achievement)
        end
    end

    def check_relation
        throw AchieverEngine::Utils::AddAutoEdgeAchievementException.new(self.parent) if (parent_id == achievement_id)
        check_cyclic
        check_superfluous_edge
        @temp_graph = nil
    end
=begin
    test if try to add a superflous edge between 2 vertices which are already connected by intermediate vertices or directly (and try to add an intermediate relations)
=end
    def check_superfluous_edge
        if @temp_graph.check_superfluous_edge(self)
            @temp_graph = nil
            throw AchieverEngine::Utils::SuperflousEdgeAchievementException.new(self.parent, self.achievement)
        end
    end

    private

    def check_relation_private(record)
        record.check_relation
    end

    def check_cyclic_private(record)
        record.check_cyclic
    end

    def check_superfluous_edge_private(record)
        record.check_superfluous_edge
    end

end

