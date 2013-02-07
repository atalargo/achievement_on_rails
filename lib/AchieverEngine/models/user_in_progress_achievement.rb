# encoding: utf-8

class UserInProgressAchievement
    include Mongoid::Document
    include Mongoid::Timestamps

    field :achievement_id, type: Integer
    field :progress, type: Float
    field :step, type: Integer, default: 1

    #     field :obtained, type: Array, default: []
    #     field :in_progress, type: Array, default: []
    #
    embedded_in :user_achievement

    validates :achievement_id, presence: true, uniqueness: true

    scope :by_user, ->(user) {where('user_achievement.user_id' => user)}
    scope :by_project, ->(project) { project.nil? ? gt('user_achievement.project_id' => 0) : where('user_achievement.project_id' => project) }
    scope :by_achievements, ->(achievements) { (achievements && achievements.size > 0) ?
                                                    where('user_achievement.in_progress.achievement_id'.to_sym.in => (achievements[0].class == Achievement ? achievements.map(&:id) : achievements)) :
                                                    gt('user_achievement.in_progress.achievement_id' => 0)
    }

end