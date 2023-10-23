class DatabaseCreation < ActiveRecord::Migration[7.0]
  def change
    
    create_table :countries do |t|
      t.string :name, null: false
      t.string :nicename, null: false
      t.string :iso, null: false
      t.string :iso3, null: false
      t.integer :num_code
      t.integer :phone_code
      t.jsonb :settings, default: {}, null: false
      t.timestamps
    end

    create_table :studies do |t|
      t.string :name, null: false
      t.string :key_name, null: false
      t.string :logo, null: false
      t.boolean :is_active, default: true, null: false
      t.boolean :is_archived, default: false, null: false
      t.jsonb :settings, default: {}, null: false
      t.timestamps
    end
    
    create_table :companies do |t|
      t.references :country, foreign_key: true, index: true, null: false
      t.string :name, null: false
      t.boolean :is_active, default: true, null: false
      t.boolean :is_archived, default: false, null: false
      t.jsonb :settings, default: {}, null: false
      t.timestamps
    end

    create_table :admins do |t|
      t.string :name, null: false
      t.string :email, null: false, index: true
      t.string :phone, index: true
      t.string :password_digest
      t.boolean :is_active, default: true, null: false
      t.boolean :is_archived, default: false, null: false
      t.jsonb :settings, default: {}, null: false
      t.timestamps
    end

    add_index :studies, :key_name, unique: true

    create_table :clients do |t|
      t.references :country, foreign_key: true, index: true
      t.references :company, foreign_key: true, index: true
      t.string :name, null: false
      t.string :logo
      t.boolean :is_client, default: true, null: false
      t.boolean :is_active, default: true, null: false
      t.boolean :is_archived, default: false, null: false
      t.jsonb :settings, default: {}, null: false
      t.timestamps
    end

    create_table :client_styles do |t|
      t.references :client, foreign_key: true, index: true, null: false
      t.boolean :is_active, default: true, null: false
      t.boolean :is_archived, default: false, null: false
      t.jsonb :settings, default: {}, null: false
      t.timestamps
    end

    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false, index: true
      t.string :phone
      t.string :password_digest
      t.integer :role, default: 0
      t.boolean :is_active, default: true, null: false
      t.boolean :is_archived, default: false, null: false
      t.jsonb :settings, default: {}, null: false
      t.timestamps
    end

    create_table :user_accesses do |t|
      t.references :client, foreign_key: true, index: true, null: false
      t.references :user, foreign_key: true, index: true
      t.boolean :is_active, default: true, null: false
      t.boolean :is_archived, default: false, null: false
      t.jsonb :settings, default: {}, null: false
      t.timestamps
    end

    create_table :client_general_results do |t|
      t.references :client, foreign_key: true, index: true, null: false
      t.integer :year, index: true
      t.boolean :is_active, default: true, null: false
      t.boolean :is_archived, default: false, null: false
      t.jsonb :results, default: {}, null: false
      t.timestamps
    end

    create_table :client_historical_results do |t|
      t.references :client, foreign_key: true, index: true, null: false
      t.integer :year, index: true
      t.boolean :is_active, default: true, null: false
      t.boolean :is_archived, default: false, null: false
      t.jsonb :results, default: {}, null: false
      t.timestamps
    end
  end
end
