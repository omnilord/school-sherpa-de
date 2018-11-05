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

ActiveRecord::Schema.define(version: 2018_11_02_175811) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "districts", force: :cascade do |t|
    t.integer "code"
    t.text "name"
    t.text "shortname"
    t.text "district_type"
    t.text "address"
    t.geography "coords", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.text "administrator"
    t.text "administrator_title"
    t.integer "students_enrolled"
    t.integer "office_code"
    t.text "profile_url"
    t.text "website_url"
    t.geography "geom", limit: {:srid=>4326, :type=>"geometry", :geographic=>true}
    t.index ["code"], name: "index_districts_on_code", unique: true
    t.index ["geom"], name: "index_districts_on_geom", using: :gist
  end

  create_table "feeder_patterns", force: :cascade do |t|
    t.text "grade_levels", array: true
    t.bigint "school_id"
    t.bigint "district_id"
    t.text "school_name"
    t.text "district_name"
    t.integer "dist_id"
    t.text "code_c"
    t.integer "code_i"
    t.geography "geom", limit: {:srid=>4326, :type=>"geometry", :geographic=>true}
    t.index ["district_id"], name: "index_feeder_patterns_on_district_id"
    t.index ["geom"], name: "index_feeder_patterns_on_geom", using: :gist
    t.index ["school_id"], name: "index_feeder_patterns_on_school_id"
  end

  create_table "raw_feeder_patterns_by_grades", primary_key: "ogc_fid", force: :cascade do |t|
    t.integer "objectid"
    t.text "school"
    t.text "district"
    t.integer "dist_id"
    t.text "code_c"
    t.integer "code_i"
    t.geography "wkb_geometry", limit: {:srid=>4326, :type=>"geometry", :geographic=>true}
    t.float "sqmiles"
    t.text "grade_level"
    t.index ["grade_level"], name: "index_raw_feeder_patterns_by_grades_on_grade_level"
    t.index ["wkb_geometry"], name: "index_raw_feeder_patterns_by_grades_on_wkb_geometry", using: :gist
  end

  create_table "schools", force: :cascade do |t|
    t.text "year"
    t.integer "code"
    t.text "name"
    t.text "school_type"
    t.bigint "district_id"
    t.text "street1"
    t.text "street2"
    t.text "city"
    t.text "state"
    t.text "zip"
    t.text "county"
    t.geography "coords", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.text "lowest_grade"
    t.text "highest_grade"
    t.text "education_level"
    t.boolean "early_care"
    t.boolean "pre_k"
    t.boolean "kindergarten"
    t.boolean "elementary"
    t.boolean "middle"
    t.boolean "high"
    t.boolean "ungraded"
    t.index ["district_id"], name: "index_schools_on_district_id"
    t.index ["year", "code"], name: "index_schools_on_year_and_code", unique: true
  end

  add_foreign_key "feeder_patterns", "districts"
  add_foreign_key "feeder_patterns", "schools"
  add_foreign_key "schools", "districts"
end
