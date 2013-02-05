
class Achievement < ActiveRecord::Base

#   include ClosureTree::ActsAsTree

    belongs_to :project

    attr_accessible :active, :name, :behaviour_type, :project_id, :steps, :on_type, :value #, :parent_id

    # 	acts_as_tree :name_column => :name

    has_and_belongs_to_many :parents, :class_name => 'Achievement', :join_table => 'achievement_relations', :association_foreign_key => :parent_id,
                        :insert_sql => proc {|record|%{
                            INSERT INTO #{AchievementRelation.table_name}(project_id, parent_id, achievement_id) VALUES (#{self.project_id}, parent_id = #{record.id}, #{self.id})
                        }}

    has_and_belongs_to_many :children, :class_name => 'Achievement', :join_table => 'achievement_relations', :association_foreign_key => :achievement_id, :foreign_key => :parent_id,
                        :insert_sql => proc {|record|%{
                            INSERT INTO #{AchievementRelation.table_name}(project_id, parent_id, achievement_id) VALUES (#{self.project_id}, #{self.id}, #{record.id} )
                        }}

    scope :by_project, lambda { |proj_id| where(:project_id => proj_id) unless proj_id.nil? }
    scope :active, lambda {  where(:active => true) }
    scope :unactive, lambda {  where(:active => false) }
    scope :typed, lambda { |type| where(:on_type => type) unless type.nil? }
    scope :in, lambda { |idlists| where(arel_table[:id].in(idlists)) unless (idlists.nil? || idlists.empty?) }

    def root?
        parents.size == 0
    end

    #
    # Get all children (not only direct children) of current achievement
    #
    def tree_children
        graph_under(self)
    end

    #
    # Get all children (not only direct children) of current achievement
    #
    def tree_parents
#         RubyProf.start
        graph_upper(self)
#         v = ""
#         RubyProf::FlatPrinter.new(RubyProf.stop).print(v)
#         Rails.logger.debug( v )
    end

    #
    # Get all achievements less achievements passed in parameter and the current achievement
    #
    def all_less(achievements)
        Achievement.all_less(achievements + [self], self.project_id)
    end

    #
    # Get roots Achievements (parent less)
    #
    def self.roots(project_id = nil)
        # Quicklest query in PostreSQL
        # SELECT "achievements".* FROM "achievements" WHERE ("achievements"."id" NOT IN (SELECT DISTINCT achievement_id FROM "achievement_relations" ));

        self.by_project(project_id).where(arel_table[:id].not_in(AchievementRelation.select(:achievement_id).by_project(project_id).uniq.arel))

    end

    #
    # Get end points Achievements (child less)
    #
    def self.end_nodes(project_id = nil)
        # Quicklest query in PostreSQL
        # SELECT "achievements".* FROM "achievements" WHERE ("achievements"."id" NOT IN (SELECT DISTINCT parent_id FROM "achievement_relations" ));

#         self.where('id NOT IN (%s)', 'SELECT DISTINCT "achievements".id FROM "achievements" INNER JOIN "achievement_relations" ON "achievements"."id" = "achievement_relations"."parent_id"').uniq

        self.by_project(project_id).where(arel_table[:id].not_in(AchievementRelation.select(:parent_id).by_project(project_id).uniq.arel))
    end

    #
    # Get all achievements with at less on parent (reverse of roots)
    #
    def self.all_children(project_id = nil)
        # Quicklest query in PostreSQL
        # SELECT "achievements".* FROM "achievements" WHERE ("achievements"."id" IN (SELECT DISTINCT achievement_id FROM "achievement_relations" ));

        self.by_project(project_id).where(arel_table[:id].in(AchievementRelation.select(:achievement_id).by_project(project_id)).uniq.arel)
    end

    #
    # Get all achievements less achievemens pass in parameter
    #
    def self.all_less(achievements, project_id = nil)
        self.by_project(project_id).where((achievements.size == 0 ? '1 = 1' : arel_table[:id].not_in(achievements.map(&:id))))
    end

    protected
    def graph_under(achievement)
        ret = achievement.children.order('created_at ASC, updated_at ASC')
#         subc = ret
        p ret
        ret.concat(ret.collect{|child|
                               p child
            graph_under(child)
        }.flatten)
#         ret.concat(subc)
    end

    def graph_upper(achievement)
        ret = achievement.parents.order('created_at ASC, updated_at ASC')
        #         subc = ret


        ret.concat(ret.collect{|parent|
            graph_upper(parent)
        }.flatten).flatten
        #         ret.concat(subc)
        #ActiveRecord::Relation.new ret
    end

end
