# encoding: utf-8

class UserAchievement
    include Mongoid::Document
    include Mongoid::Timestamps

    field :user_id, type: Integer
    field :version, type: Integer

    embeds_many :obtained, validate: false, class_name: 'UserObtainedAchievement' #, autosave: true
    embeds_many :in_progress, validate: false, class_name: 'UserInProgressAchievement' #, autosave: true

    validates :user_id, presence: true, uniqueness: true

    index({'obtained.achievement_id' => 1}, {background: true, unique: true})
    index({'in_progress.achievement_id'=> 1}, {background: true, unique: true})

    # Return scope for select UserAchievement for the user passed in param
    #
    # @example
    #   by_user(1)
    #
    # @example
    #   by_user(klass)
    #
    # @param [Integer or Klass] Integer fot the user id or a class responding to id call
    #
    scope :by_user, ->(user) { where(user_id: (user.is_a?(Integer) ? user : user.id)) }

    # Return scope for select UserAchievement which have achievements (obtained or in progress) passed in params
    #
    # Mongo translation : db.user_achievements.find({'$or': [{'in_progress.achievement_id': {'$in': [1]}}, {'obtained.achievement_id': {'$in': [1]}}]})
    #
    # @example select user_achievements which have achievements 1 or 50 in obtained list or in in_progress list
    #           by_achievements([1,50])
    # @example select user_achievements which have achievements at less one obtained achievement or one in_progress list
    #           by_achievements()
    #
    # @param [Array] or [nil] list of achievements.
    #           It could be :
    #           * array of integer (achievement's ids),
    #           * array of achievements class,
    #           * nil (in this the query return user_achievement with at less 1 obtained achievement)
    #
    scope :by_achievements, ->(list_achievement = nil) {
        if list_achievement
            achievement_list = ((list_achievement[0].is_a? Achievement) ? list_achievement.map(&:id) : list_achievement  )
            criteria.selector.merge!({'or' => [
                                                            {'in_progress.achievement_id' => {'$in' => achievement_list}},
                                                            {'obtained.achievement_id' => {'$in' => achievement_list}}
            ]})
        else
            criteria.selector.merge!({ 'or' => [
                                    {'in_progress.achievement_id' => {'$gt' => 0}},
                                    {'obtained.achievement_id' => {'$gt' => 0}}
            ]})
        end
    }

    # Return scope for select UserAchievement which have achievements passed in params in their obtained list
    #
    # @example select user_achievements which have achievements 1 or 50 in obtained list
    #           for_obtained([1,50])
    # @example select user_achievements which have achievements at less one obtained achievement
    #           for_obtained()
    #
    # @param [Array] or [nil] list of achievements.
    #           It could be :
    #           * array of integer (achievement's ids),
    #           * array of achievements class,
    #           * nil (in this the query return user_achievement with at less 1 obtained achievement)
    #
    scope :for_obtained, ->(list_achievement = nil) {
                                (!list_achievement || list_achievement.count == 0) ?
                                #where('obtained.achievement_id'.to_sym.gt => 0)
                                gt('obtained.achievement_id' => 0) :
                                where('obtained.achievement_id'.to_sym.in =>
                                    ((list_achievement[0].is_a? Achievement) ? list_achievement.map(&:id) : list_achievement  )
                                )
    }

    # Return scope for select UserAchievement which have achievements passed in params in their in_progress list
    #
    # @example select user_achievements which have achievements 1 or 50 in in_progress list
    #           for_in_progress([1,50])
    # @example select user_achievements which have achievements at less one in_progress achievement
    #           for_in_progress()
    #
    # @param [Array] or [nil] list of achievements.
    #           It could be :
    #           * array of integer (achievement's ids),
    #           * array of achievements class,
    #           * nil (in this the query return user_achievement with at less 1 in_progress achievement)
    #
    scope :for_in_progress, ->(list_achievement = nil) {
                                (!list_achievement || list_achievement.count == 0) ?
                                gt('in_progress.achievement_id' => 0) :
                                where('in_progress.achievement_id'.to_sym.in =>
                                    ((list_achievement[0].is_a? Achievement) ? list_achievement.map(&:id) : list_achievement  )
                                )
    }

    def all_achievements
        {:obtained => self.obtained, :in_progress => self.in_progress}
    end

end
