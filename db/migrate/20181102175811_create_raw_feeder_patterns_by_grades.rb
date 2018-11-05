class CreateRawFeederPatternsByGrades < ActiveRecord::Migration[5.2]
  def change
    create_table :raw_feeder_patterns_by_grades, id: false do |t|
      t.primary_key :ogc_fid
      t.integer :objectid
      t.text :school
      t.text :district
      t.integer :dist_id
      t.text :code_c
      t.integer :code_i
      t.geometry :wkb_geometry, geographic: true
      t.float :sqmiles
      t.text :grade_level, index: true
    end

    add_index :raw_feeder_patterns_by_grades, :wkb_geometry, using: :gist
  end
end
