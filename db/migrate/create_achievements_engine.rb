class CreateAchievementsEngine < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.integer :project_id, :null => false
      t.string  :name, :null => false
      t.string  :behaviour_type, :null => false
      t.boolean :active, :null => false, :default => false, :null => false
      t.string  :on_type, :null => false
      t.integer :steps, :null => false, :default => 1
      t.integer :value, :null => false

      t.timestamps
    end
    add_index :achievements, [:project_id, :name], :unique => true
    add_index :achievements, [:project_id, :active, :behaviour_type,:on_type], {:name => 'project_active_behav_type_idx'}
    add_index :achievements, [:project_id, :active,:on_type], {:name => 'project_on_active_type_idx'}

    create_table :achievement_relations, :id => false  do |t|
       t.integer   :project_id, :null => false
       t.integer   :parent_id, :null => false
       t.integer   :achievement_id, :null => false
       t.timestamp :created_at, :null => false
    end

    add_index :achievement_relations, [:project_id, :parent_id, :achievement_id], {:unique => true, :primary_key => true, :name => 'ar_project_parent_achivement_idx'}
    add_index :achievement_relations, [:project_id, :achievement_id], {:name => 'ar_project_on_achivement_idx'}

  end

  def down
    drop_table :achievement_relations
    drop_table :achievements
  end
end

