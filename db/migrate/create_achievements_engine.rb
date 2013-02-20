class CreateAchievementsEngine < ActiveRecord::Migration
  def self.up
    create_table :achievements do |t|
      t.string  :name, :null => false
      t.string  :behaviour_type, :null => false
      t.boolean :active, :null => false, :default => false, :null => false
      t.string  :on_type, :null => false
      t.integer :steps, :null => false, :default => 1
      t.integer :value, :null => false

      t.timestamps
    end
    add_index :achievements, [ :name], :unique => true
    add_index :achievements, [:active, :behaviour_type,:on_type], {:name => 'active_behav_type_idx'}
    add_index :achievements, [:active,:on_type], {:name => 'on_active_type_idx'}

    create_table :achievement_relations, :id => false  do |t|
       t.integer   :parent_id, :null => false
       t.integer   :achievement_id, :null => false
       t.timestamp :created_at, :null => false
    end

    add_index :achievement_relations, [:parent_id, :achievement_id], {:unique => true, :primary_key => true, :name => 'ar_parent_achivement_idx'}
    add_index :achievement_relations, [:achievement_id], {:name => 'ar_on_achivement_idx'}

  end

  def self.down
    drop_table :achievement_relations
    drop_table :achievements
  end
end

