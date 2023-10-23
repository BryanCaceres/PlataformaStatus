# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_10_23_172131) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "password_digest"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_archived", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email"
    t.index ["phone"], name: "index_admins_on_phone"
  end

  create_table "client_general_results", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.integer "year"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_archived", default: false, null: false
    t.jsonb "results", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_client_general_results_on_client_id"
    t.index ["year"], name: "index_client_general_results_on_year"
  end

  create_table "client_historical_results", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.integer "year"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_archived", default: false, null: false
    t.jsonb "results", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_client_historical_results_on_client_id"
    t.index ["year"], name: "index_client_historical_results_on_year"
  end

  create_table "client_styles", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_archived", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_client_styles_on_client_id"
  end

  create_table "clients", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.bigint "company_id"
    t.string "name", null: false
    t.string "logo"
    t.boolean "is_client", default: true, null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_archived", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_clients_on_company_id"
    t.index ["country_id"], name: "index_clients_on_country_id"
  end

  create_table "companies", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.string "name", null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_archived", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_companies_on_country_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "nicename", null: false
    t.string "iso", null: false
    t.string "iso3", null: false
    t.integer "num_code"
    t.integer "phone_code"
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feature_flags", force: :cascade do |t|
    t.string "title", null: false
    t.string "name", null: false
    t.boolean "is_active", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "studies", force: :cascade do |t|
    t.string "name", null: false
    t.string "key_name", null: false
    t.string "logo", null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_archived", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_name"], name: "index_studies_on_key_name", unique: true
  end

  create_table "user_accesses", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "user_id"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_archived", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_user_accesses_on_client_id"
    t.index ["user_id"], name: "index_user_accesses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "password_digest"
    t.integer "role", default: 0
    t.boolean "is_active", default: true, null: false
    t.boolean "is_archived", default: false, null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "client_general_results", "clients"
  add_foreign_key "client_historical_results", "clients"
  add_foreign_key "client_styles", "clients"
  add_foreign_key "clients", "companies"
  add_foreign_key "clients", "countries"
  add_foreign_key "companies", "countries"
  add_foreign_key "user_accesses", "clients"
  add_foreign_key "user_accesses", "users"
end
