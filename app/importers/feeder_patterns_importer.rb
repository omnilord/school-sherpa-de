require 'rgeo/geo_json'

class FeederPatternsImporter
  SRC = Rails.root.join('db', 'seed_files', 'Grade_%{filter}.geojson').to_s
  ALLOWED_GEOMETRIES = %q[Polygon MultiPolygon].freeze
  DEBUGGING = Rails.env.development?
  VERTICES_SIZES = Array.new

  def self.import
    set_district_geometry
    set_feeder_patterns
    link_feeder_patterns_to_models
  end

private

  def self.set_district_geometry
    without_geom_before = District.where(geom: nil).count
    sql = <<~SQL
      UPDATE districts SET geom=(
        SELECT st_union(raw_feeder_patterns_by_grades.wkb_geometry::geometry)
        FROM raw_feeder_patterns_by_grades
        WHERE raw_feeder_patterns_by_grades.dist_id = districts.code
      ) WHERE geom IS NULL
    SQL
    ActiveRecord::Base.connection.execute(sql)
    without_geom_after = District.where(geom: nil).count
    puts "#{without_geom_before - without_geom_after} `geom` records set out of #{District.count} districts."
  end

  def self.set_feeder_patterns
    before = FeederPattern.count
    sql = <<~SQL
      INSERT INTO feeder_patterns (grade_levels, school_name, district_name, dist_id, code_c, code_i, geom)
        SELECT array_agg(DISTINCT grade_level), (array_agg(school))[1], (array_agg(district))[1],
               (array_agg(dist_id))[1], (array_agg(code_c))[1], (array_agg(code_i))[1],
               ST_union(wkb_geometry::geometry)
        FROM raw_feeder_patterns_by_grades
        GROUP BY code_i
    SQL
    ActiveRecord::Base.connection.execute(sql)
    after = FeederPattern.count
    puts "Created #{after - before} Feeder Pattern Records."
  end

  def self.link_feeder_patterns_to_models
    counter = 0
    FeederPattern.all.each do |fp|
      fp.school = School.find_by(code: fp.code_i)
      puts "School '#{fp.school_name} (#{fp.code_i})' not fould for feeder pattern #{fp.id}" if fp.school.nil?
      fp.district = District.find_by(code: fp.dist_id)
      puts "District '#{fp.district_name} (#{fp.dist_id})' not fould for feeder pattern #{fp.id}" if fp.district.nil?

      if fp.changed?
        fp.save
        counter += 1
        puts "Links saved for #{fp.school&.name || fp.school_name} in #{fp.district&.name || fp.district_name}"
      end
    end
  end


# These are old functions for reference now and deletion later

  def self.old_import
    Dir[format(SRC, filter: '*')].each do |path|
      grade = File.basename(path, '.geojson')[6..-1].downcase
      puts "starting import for grade #{grade}"
      geodata = JSON.parse(File.read(path), symbolize_names: true)
      counter = stow_patterns(grade, geodata[:features])
      puts "#{counter} patterns imported for grade #{grade}"
    end
  end

  def self.stow_patterns(grade_level, features)
    counter = 0
    features.each do |feature|
      next if feature[:type] != 'Feature'
      next unless ALLOWED_GEOMETRIES.include?(feature[:geometry][:type])

      counter += 1 if save_pattern(grade_level, feature[:properties], feature[:geometry])
    end
    counter
  end

  def self.save_pattern(grade_level, props, geometry)
    fp = FeederPattern.where(grade_level: grade_level, dist_id: props[:DIST_ID].to_i, code_c: props[:CODE_C].to_i)
                  .first_or_create do |fp|
      fp.grade_level = grade_level
      fp.dist_id = props[:DIST_ID].to_i
      fp.code_c = props[:CODE_C].to_i
      fp.code_i = props[:CODE_I].to_i
      fp.school_name = props[:SCHOOL]
      fp.district_name = props[:DISTRICT]

      fp.school = School.find_by(code: props[:CODE_C].to_i)
      puts "Missing School #{props[:CODE_C]},#{props[:CODE_I]}" if fp.school.nil?

      fp.district = District.find_by(code: props[:DIST_ID].to_i)
      puts "Missing District #{props[:DIST_ID]}" if fp.district.nil?
    end.tap do |fp|
      ActiveRecord::Base.logger.silence do
        geom = RGeo::GeoJSON.decode(geometry.to_json).as_text
        sql = "UPDATE feeder_patterns SET geom='#{geom}' WHERE id=#{fp.id}"
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end
end
