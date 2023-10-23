class AddFeaturedFlagTable < ActiveRecord::Migration[7.0]
  def change
    create_table :feature_flags do |t|
      t.string :title, null: false
      t.string :name, null: false
      t.boolean :is_active, null: false, default: false
      t.jsonb :settings, null: false, default: {}
      
      t.timestamps
    end
  end
end
