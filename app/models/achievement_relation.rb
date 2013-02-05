class AchievementRelation < ActiveRecord::Base

    attr_accessible :achievement_id, :parent_id, :project_id, :created_at, :updated_at
    belongs_to :achievement, :class_name => 'Achievement'
    belongs_to :parent, :class_name => 'Achievement'
    belongs_to :project


    scope :by_project, lambda { |proj_id| where(:project_id => proj_id) unless proj_id.nil? }
    scope :by_parent, lambda { |parent_id| where(:parent_id => parent_id) unless parent_id.nil? }
    scope :by_child, lambda { |child_id| where(:achievement_id => child_id) unless child_id.nil? }

    before_validation :add_project_before

    def self.all_ids(options)
        ids = []
        self.by_project(options[:project_id]).each do |ar|
            ids.push ar.achievement_id,ar.parent_id
        end
        ids.uniq
    end

    def add_project_before
        Rails.logger.debug(self.project_id)
        Rails.logger.debug(self.parent)
        Rails.logger.debug(self.parent.project_id)
        self.project_id = self.parent.project_id
        Rails.logger.debug(self.project_id)
    end


end

