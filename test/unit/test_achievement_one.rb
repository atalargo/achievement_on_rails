
require 'test/unit'

require 'support_test'
require 'ar_model_helper'

class TestAchievementOne < ActiveSupport::TestCase

    def test_1_select_achievement
        assert_equal Achievement.all.count, 0
    end

    def test_2_validate_achievement
        assert_equal Achievement.new(achievements('one')).valid?, false
        assert_raise(ActiveRecord::RecordInvalid){
            Achievement.new(achievements('one')).save!
        }
    end

    def test_3_insert_achievement
        assert_equal Achievement.new(achievements('two')).valid?, true
        assert_nothing_raised {
            Achievement.new(achievements('two')).save
        }
    end

    def test_4_insert_achievement
        assert_raise(ActiveRecord::RecordNotUnique){
            Achievement.new(achievements('two')).save
        }
        assert_nothing_raised {
            Achievement.new(achievements('three')).save!
        }
    end

    def test_5_active_achievement
        assert_equal Achievement.where(:active => true).all.count, 0
        assert_equal Achievement.where(:active => false).all.count, Achievement.all.count


        assert_nothing_raised {
            ach1 = Achievement.find(1)
            ach1.active = true
            ach1.save
        }
        assert_equal 1, Achievement.where(:active => true).all.count
        assert_equal 1, Achievement.where(:active => false).all.count

        assert_equal 1, Achievement.active.all.count
        assert_equal 1, Achievement.unactive.all.count

    end

    def test_6_scope_achievement
        assert_equal 2, Achievement.typed(:points).all.count

        assert_equal 2, Achievement.in([1,2]).all.count
    end

    def test_6_hierarchy_achievement

        assert_equal 0, Achievement.first.parents.count

        assert_equal 0, Achievement.first.children.count

        alls = Achievement.includes(:children, :parents).all
        assert_equal 2, alls.count
        assert_equal 0, alls.first.children.count
        assert_equal 0, alls.first.parents.count

    end

end

