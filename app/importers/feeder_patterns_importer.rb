require 'rgeo/geo_json'

class FeederPatternsImporter
  SRC = Rails.root.join('db', 'seed_files', 'Grade_%{filter}.geojson').to_s
  ALLOWED_GEOMETRIES = %q[Polygon MultiPolygon].freeze
  DEBUGGING = Rails.env.development?
  VERTICES_SIZES = Array.new

  def self.import
    Dir[format(SRC, filter: '*')].each do |path|
      grade = File.basename(path, '.geojson')[6..-1].downcase
      puts "starting import for grade #{grade}"
      geodata = JSON.parse(File.read(path), symbolize_names: true)
      counter = stow_patterns(grade, geodata[:features])
      puts "#{counter} patterns imported for grade #{grade}"
    end
  end

private

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
