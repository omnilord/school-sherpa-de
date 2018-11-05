class SherpaImportBasics < ActiveRecord::Migration[5.2]
  def change
    create_table :districts do |t|
      t.integer :code, index: { unique: true }
      t.text :name
      t.text :shortname
      t.text :district_type
      t.text :address
      t.st_point :coords, geographic: true
      t.text :administrator
      t.text :administrator_title
      t.integer :students_enrolled
      t.integer :office_code
      t.text :profile_url
      t.text :website_url
      t.geometry :geom, geographic: true
    end

    add_index :districts, :geom, using: :gist

    create_table :schools do |t|
      t.text :year
      t.integer :code
      t.text :name
      t.text :school_type
      t.references :district, foreign_key: true
      t.text :street1
      t.text :street2
      t.text :city
      t.text :state
      t.text :zip
      t.text :county
      t.st_point :coords, geographic: true
      t.text :lowest_grade
      t.text :highest_grade
      t.text :education_level
      t.boolean :early_care
      t.boolean :pre_k
      t.boolean :kindergarten
      t.boolean :elementary
      t.boolean :middle
      t.boolean :high
      t.boolean :ungraded
    end

    add_index :schools, [:year, :code], unique: true

    create_table :feeder_patterns do |t|
      t.text :grade_levels, array: true
      t.references :school, foreign_key: true
      t.references :district, foreign_key: true
      t.text :school_name
      t.text :district_name
      t.integer :dist_id
      t.text :code_c
      t.integer :code_i
      t.geometry :geom, geographic: true
    end

    add_index :feeder_patterns, :geom, using: :gist

  end
end
