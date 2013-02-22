require 'composite_primary_keys'

class AchievementRelation < ActiveRecord::Base

    attr_accessible :achievement_id, :parent_id, :created_at, :updated_at

    self.primary_keys = :parent_id, :achievement_id

    belongs_to :achievement, :class_name => 'Achievement'
    belongs_to :parent,      :class_name => 'Achievement'

    @force_superflous = false

    scope :by_parent,   lambda { |parent_id| where(:parent_id => parent_id) unless parent_id.nil? }
    scope :by_child,    lambda { |child_id| where(:achievement_id => child_id) unless child_id.nil? }

    before_save         :check_relation_private


    validates :achievement_id,  :presence => true
    validates :parent_id,       :presence => true

    def self.all_ids(options)
        ids = []
        self.all.each do |ar|
            ids.push ar.achievement_id,ar.parent_id
        end
        ids.uniq
    end

    def delete
        self.class.delete(self.id)
    end

    def force_superflous_edge!
        @force_superflous = true
        self
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
        @temp_graph = AchieverEngine::Graph.create_nanoc_directed_graph(Achievement.includes(:children).all) if @temp_graph.nil?
        if @temp_graph.check_cyclic_for_egde(self)
            @temp_graph = nil
            raise AchieverEngine::Utils::AddCyclicGraphAchievementException.new(self.parent, self.achievement)
        else
            @temp_graph = nil
        end
    end

    def check_relation
#         raise AchieverEngine::Utils::AlreadyDefinedEdgeAchievementException.new(self.parent, self.achievement) if (self.parent.children.include?(self.achievement))
        raise AchieverEngine::Utils::AddAutoEdgeAchievementException.new(self.parent) if (parent_id == achievement_id)
        check_cyclic
        check_superfluous_edge
        @temp_graph = nil
    end
=begin
    test if try to add a superflous edge between 2 vertices which are already connected by intermediate vertices or directly (and try to add an intermediate relations)
=end
    def check_superfluous_edge
        @temp_graph = AchieverEngine::Graph.create_nanoc_directed_graph(Achievement.includes(:children).all) if @temp_graph.nil?
        if @temp_graph.check_superfluous_edge(self)
            @temp_graph = nil
            raise AchieverEngine::Utils::SuperflousEdgeAchievementException.new(self.parent, self.achievement) if !@force_superflous
            @force_superflous = false
        else
            @temp_graph = nil
            @force_superflous = false
        end
    end


    def rel_save_sql
        values = arel_attributes_values(!id.nil?)
        substitutes = values.sort_by { |arel_attr,_| arel_attr.name }
        substitutes.each_with_index do |tuple, i|
            substitutes[i][1] = Time.now if tuple[0].name =~ /_at$/
        end
        cri = AchievementRelation.arel_table.create_insert
        cri.into AchievementRelation.arel_table.name

        cri.insert substitutes
        cri.to_sql
    end

    def rel_delete_sql
        wheres = []
        arel_attributes_values(!id.nil?).each_with_index do |tuple, i|
            wheres << tuple[0].name + " = #{tuple[1]}" if tuple[0].name !~ /_at$/
        end
        'DELETE FROM '+ self.class.arel_table.name + ' WHERE ' + wheres.join(' AND ')
    end

    private

    def check_relation_private(record = nil)
        record = self if record.nil?
        record.check_relation
    end

    def check_cyclic_private(record = nil)
        record = self if record.nil?
        record.check_cyclic
    end

    def check_superfluous_edge_private(record = nil)
        record = self if record.nil?
        record.check_superfluous_edge
    end

end

