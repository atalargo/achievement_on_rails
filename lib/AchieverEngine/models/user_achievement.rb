# encoding: utf-8

class UserAchievement
    include Mongoid::Document
    include Mongoid::Timestamps

    field :user_id, type: Integer
    field :version, type: Integer

#     field :obtained, type: Array, default: []
#     field :in_progress, type: Array, default: []
#
    embeds_many :obtained, validate: false, class_name: 'UserObtainedAchievement' #, autosave: true
    embeds_many :in_progress, validate: false, class_name: 'UserInProgressAchievement' #, autosave: true

#     field: achievement_id, type: integer
#     field: progress, type: float
    validates :user_id, presence: true, uniqueness: true

    index({'obtained.achievement_id' => 1}, {background: true, unique: true})
    index({'in_progress.achievement_id'=> 1}, {background: true, unique: true})

    scope :by_user, ->(user) { where(user_id: user) }
    scope :for_obtained, ->(list_achievement) {
                                (!list_achievement || list_achievement.count == 0) ?
                                #where('obtained.achievement_id'.to_sym.gt => 0)
                                gt('obtained.achievement_id' => 0) :
                                where('obtained.achievement_id'.to_sym.in =>
                                    ((list_achievement[0].is_a? Achievement) ? list_achievement.map(&:id) : list_achievement  )
                                )
    }
    scope :for_in_progress, ->(list_achievement) {
                                (!list_achievement || list_achievement.count == 0) ?
                                gt('in_progress.achievement_id' => 0) :
                                where('in_progress.achievement_id'.to_sym.in =>
                                    ((list_achievement[0].is_a? Achievement) ? list_achievement.map(&:id) : list_achievement  )
                                )
    }

    def all_achievements
        {:obtained => self.obtained, :in_progress => self.in_progress}
    end

#     def obtained
#         self[:obtained]
#     end
#
#     def in_progress
#         self[:in_progress]
#     end

    def self.obtained
        :obtained
    end

    def self.in_progress
        :in_progress
    end

end