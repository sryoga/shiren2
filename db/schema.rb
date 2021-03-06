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


ActiveRecord::Schema.define(version: 2020_06_15_000142) do

  create_table "dungeons", force: :cascade do |t|
    t.string "name"
    t.integer "cuttime"
    t.text "regulation"
    t.string "uriname"
    t.string "dungeoncolor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
    
  create_table "banners", force: :cascade do |t|
    t.text "image_url"
    t.string "title"
    t.text "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "display_by"
  end

  create_table "items", force: :cascade do |t|
    t.text "name"
    t.text "type"
    t.integer "buy"
    t.integer "sell"
    t.integer "buydif"
    t.integer "selldif"
    t.integer "mincnt"
    t.integer "maxcnt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "kind"
  end

  create_table "opinions", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ranks", force: :cascade do |t|
    t.text "name"
    t.integer "result"
    t.text "movie"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recordimage"
    t.boolean "permission", default: false
    t.integer "user_id"
    t.boolean "rejection", default: false
    t.text "rejectioncomment"
    t.text "remark"
    t.boolean "beforeseason", default: false
    t.integer "dungeon_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.text "name"
    t.text "eventdate"
    t.text "organizer"
    t.text "rule"
    t.text "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.string "icon"
    t.string "niconico"
    t.string "youtube"
    t.string "cavetube"
    t.string "twitch"
    t.boolean "admin", default: false
    t.text "introduction"
    t.boolean "super_admin"
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
