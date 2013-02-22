
class Achievement < ActiveRecord::Base


    attr_accessible :active, :name, :behaviour_type, :steps, :on_type, :value

    has_and_belongs_to_many :parents, :class_name => 'Achievement', :join_table => 'achievement_relations', :association_foreign_key => :parent_id,
                        :before_add => :relation_validator_parent, :insert_sql => lambda {|record|
                            AchievementRelation.new(:parent_id => record.id, :achievement_id => self.id).rel_save_sql
                        }

    has_and_belongs_to_many :children, :class_name => 'Achievement', :join_table => 'achievement_relations', :foreign_key => :parent_id,
                        :before_add => :relation_validator_child, :insert_sql => lambda {|record|
                            AchievementRelation.new(:parent_id => self.id, :achievement_id => record.id).rel_save_sql
                        }

#     has_many :achievement_relations_children, :class_name => 'AchievementRelation', :foreign_key => :parent_id
#     has_many :children, :class_name => 'Achievement', :through => :achievement_relations_children, :foreign_key => :parent_id, :source => :achievement
#     :destroy :association_foreign_key => :achievement_id,

    scope :active, lambda {  where(:active => true) }
    scope :unactive, lambda {  where(:active => false) }
    scope :typed, lambda { |type| where(:on_type => type) unless type.nil? }
    scope :in, lambda { |idlists| where(arel_table[:id].in(idlists)) unless (idlists.nil? || idlists.empty?) }


    before_create   :check_create_cyclic
    before_update   :check_update_cyclic


    validates :behaviour_type,  :presence => true
    validates :name,            :presence => true
    validates :on_type,         :presence => true


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
        Achievement.all_less(achievements + [self])
    end

    #
    # Get roots Achievements (parent less)
    #
    def self.roots
        # Quicklest query in PostreSQL
        # SELECT "achievements".* FROM "achievements" WHERE ("achievements"."id" NOT IN (SELECT DISTINCT achievement_id FROM "achievement_relations" ));

        self.where(arel_table[:id].not_in(AchievementRelation.select(:achievement_id).uniq.arel))

    end

    #
    # Get end points Achievements (child less)
    #
    def self.end_nodes
        # Quicklest query in PostreSQL
        # SELECT "achievements".* FROM "achievements" WHERE ("achievements"."id" NOT IN (SELECT DISTINCT parent_id FROM "achievement_relations" ));

#         self.where('id NOT IN (%s)', 'SELECT DISTINCT "achievements".id FROM "achievements" INNER JOIN "achievement_relations" ON "achievements"."id" = "achievement_relations"."parent_id"').uniq

        self.where(arel_table[:id].not_in(AchievementRelation.select(:parent_id).uniq.arel))
    end

    #
    # Get all achievements with at less on parent (reverse of roots)
    #
    def self.all_children
        # Quicklest query in PostreSQL
        # SELECT "achievements".* FROM "achievements" WHERE ("achievements"."id" IN (SELECT DISTINCT achievement_id FROM "achievement_relations" ));

        self.where(arel_table[:id].in(AchievementRelation.select(:achievement_id).uniq.arel))
    end

    #
    # Get all achievements less achievemens pass in parameter
    #
    def self.all_less(achievements)
        self.where((achievements.size == 0 ? '1 = 1' : arel_table[:id].not_in(achievements.map(&:id))))
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

    private

    def check_create_cyclic(record = nil)
        record = self if record.nil?
        p "check_create_cyclic"
        !AchieverEngine::Graph.create_nanoc_directed_graph(Achievement.includes(:children).all).check_cyclic_for_vertex(record)
    end

    def check_update_cyclic(record = nil)
        record = self if record.nil?
        p "check_update_cyclic"
        check_create_cyclic(record)
    end

    def relation_validator_child(record)
        relation_validator(self, record)
    end

    def relation_validator_parent(record)
        relation_validator(record, self)
    end

    def relation_validator(parent, child)
       AchievementRelation.check_relation(parent, child)
    end

end
