require 'rgeo/geo_json'

class FeederPatternsImporter
  SRC = Rails.root.join('db', 'seed_files', 'Grade_*.geojson')
  ALLOWED_GEOMETRIES = %q[Polygon MultiPolygon].freeze

  def self.import
    Dir[SRC].each do |path|
      grade = File.basename(path, '.geojson')[6..-1].downcase
      puts "starting import for grade #{grade}"
      geodata = JSON.parse(File.read(path), symbolize_names: true)
      counter = stow_patterns(grade, geodata[:features])
      puts "#{counter} patterns imported for grade #{grade}"
    end
  end

private

  def self.stow_patterns(grade, features)
    counter = 0
    features.each do |feature|
      next if feature[:type] != 'Feature'
      next unless ALLOWED_GEOMETRIES.include?(feature[:geometry][:type])

      props = feature[:properties]
      data = {
        grade_level: grade,
        dist_id: props[:DIST_ID].to_i,
        code_c: props[:CODE_C].to_i,
        code_i: props[:CODE_I].to_i,
        school_name: props[:SCHOOL],
        district_name: props[:DISTRICT].upcase,
        geom: RGeo::GeoJSON.decode(feature[:geometry].to_json).as_text
      }
      data[:school] = School.find_by(code: data[:code_c])
      data[:district] = District.find_by(code: data[:dist_id])

      puts "Missing School #{data[:code_c]},#{data[:code_i]}" if data[:school].nil?
      puts "Missing District #{data[:dist_id]}" if data[:district].nil?

      counter += 1  if FeederPattern.create!(data)
    end
    counter
  end
end
