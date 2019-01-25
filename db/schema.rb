# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_25_075643) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bonus", force: :cascade do |t|
    t.float "std"
    t.float "percent"
    t.bigint "cv_investment_interval_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cv_investment_interval_id"], name: "index_bonus_on_cv_investment_interval_id"
  end

  create_table "cv_intervals", force: :cascade do |t|
    t.float "min"
    t.float "max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cv_investment_intervals", force: :cascade do |t|
    t.bigint "cv_interval_id"
    t.bigint "investment_interval_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cv_interval_id"], name: "index_cv_investment_intervals_on_cv_interval_id"
    t.index ["investment_interval_id"], name: "index_cv_investment_intervals_on_investment_interval_id"
  end

  create_table "investment_intervals", force: :cascade do |t|
    t.float "min"
    t.float "max"
    t.decimal "group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "investments", force: :cascade do |t|
    t.bigint "user_id"
    t.float "amount"
    t.float "wallet_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_investments_on_user_id"
  end

  create_table "unit_bonus", force: :cascade do |t|
    t.string "stdv_float"
    t.bigint "investment_interval_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["investment_interval_id"], name: "index_unit_bonus_on_investment_interval_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bonus", "cv_investment_intervals"
  add_foreign_key "cv_investment_intervals", "cv_intervals"
  add_foreign_key "cv_investment_intervals", "investment_intervals"
  add_foreign_key "investments", "users"
  add_foreign_key "unit_bonus", "investment_intervals"
end
