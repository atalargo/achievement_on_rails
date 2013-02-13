# encoding: utf-8

class UserObtainedAchievement
    include Mongoid::Document
    include Mongoid::Timestamps

    field :achievement_id, type: Integer
    field :steps, type: Integer, default: 1

    #     field :obtained, type: Array, default: []
    #     field :in_progress, type: Array, default: []
    #
    embedded_in :user_achievement

    validates :achievement_id, presence: true, uniqueness: true

    scope :by_user, ->(user) {where('user_achievement.user_id' => user)}
    scope :by_achievements, ->(achievements) { (achievements && achievements.size > 0) ?
                                                    where(:achievement_id.in => (
                                                                achievements[0].class == Achievement ? achievements.map(&:id) :
                                                                achievements
                                                            )
                                                    ) :
                                                    gt(:achievement_id => 0)
    }

end