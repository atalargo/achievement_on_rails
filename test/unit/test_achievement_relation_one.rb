
require 'test/unit'
require 'support_test'
require 'ar_model_helper'

class TestAchievementRelationOne < ActiveSupport::TestCase

    def test_1_good_relation
        assert_nothing_raised{
            AchievementRelation.new(achievement_relations('two_three')).save!
        }
    end

    def test_2_bad_relation_auto
        assert_raise(AchieverEngine::Utils::AddAutoEdgeAchievementException){
            AchievementRelation.new(achievement_relations('two_two')).save!
        }
    end

    def test_3_bad_relation_cyclic
        assert_raise(AchieverEngine::Utils::AddCyclicGraphAchievementException){
            AchievementRelation.new(achievement_relations('three_two')).save!
        }
    end

    def test_4_bad_relation_superflous
        Achievement.new(achievements('four')).save!
        AchievementRelation.new(achievement_relations('three_four')).save!

        assert_raise(AchieverEngine::Utils::SuperflousEdgeAchievementException){
            AchievementRelation.new(achievement_relations('two_four')).save!
        }
    end

    def test_5_relation_superflous_forced

        assert_nothing_raised(AchieverEngine::Utils::SuperflousEdgeAchievementException){
            AchievementRelation.new(achievement_relations('two_four')).force_superflous_edge!.save!
        }
    end

    def test_6_good_by_children

        assert_nothing_raised(AchieverEngine::Utils::SuperflousEdgeAchievementException){
            ach = Achievement.new(achievements('five'))
            ach.save
            Achievement.find(1).children << ach
        }
    end

    def test_7_delete_relation_direct
        assert_nothing_raised {
            AchievementRelation.find(1,3).delete
        }
        AchievementRelation.new(achievement_relations('two_four')).force_superflous_edge!.save!
        assert_nothing_raised {
            AchievementRelation.delete(AchievementRelation.find(1,3).id)
        }
    end

    def test_8_delete_relation_by_achievements
        AchievementRelation.new(achievement_relations('two_four')).force_superflous_edge!.save!
        assert_nothing_raised() {
            Achievement.find(1).children.delete(Achievement.find(3))
        }
        assert_raise(ActiveRecord::RecordNotFound){
            AchievementRelation.find(1,3)
        }
    end
end
