require 'rgeo/geo_json'

class FeederPatternsImporter
  SRC = Rails.root.join('db', 'seed_files', 'Grade_%{filter}.geojson').to_s
  ALLOWED_GEOMETRIES = %q[Polygon MultiPolygon].freeze
  DEBUGGING = Rails.env.development?
  VERTICES_SIZES = Array.new

  def self.backfill
    list = FeederPattern.where(geom: nil)
    filters = list.map { |p| p.grade_level }.uniq
    filters.each do |grade_level|
      puts "backfilling grade #{grade_level}"
      counter = backfill_grade_level(grade_level, list.select { |item| item.grade_level == grade_level })
      puts "#{counter} grade #{grade_level} backfilled"
    end

    if DEBUGGING
      VERTICES_SIZES.sort { |a, b| a[:size] <=> b[:size] }.each { |v| puts v.inspect }
    end

    check = FeederPattern.where(geom: nil)
    failures, successes = list.partition { |obj| check.include? obj }
    puts "Backfill Failures: #{failures.length}"
    puts "Backfull Successes: #{successes.length}"
    successes.each do |fp|
      File.delete(Rails.root.join('tmp', 'seeding', "feeder_pattern_#{fp.grade_level}_#{fp.code_c}.dump"))
    end
  end

private

  def self.backfill_grade_level(grade_level, list)
    counter = 0
    path = format(SRC, filter: grade_level.capitalize)
    geodata = JSON.parse(File.read(path), symbolize_names: true)
    puts "#{geodata[:features].length} patterns in #{path}"
    geodata[:features].each do |feature|
      if DEBUGGING
        VERTICES_SIZES << {
          grade_level: grade_level,
          code: feature[:properties][:CODE_C].to_i,
          size: feature[:geometry][:coordinates].reduce(0) { |m, p| m + p.length }
        }
      end

      if pattern = find_feeder(list, feature[:properties])
        VERTICES_SIZES.last[:FAILED_IMPORT] = true if DEBUGGING
        counter += 1 if update_pattern(grade_level, feature, pattern)
      end
    end
    counter
  end

  def self.find_feeder(list, props)
    index = list.find_index do |feeder|
      feeder.dist_id == props[:DIST_ID].to_i &&
      feeder.code_c == props[:CODE_C].to_i &&
      feeder.code_i == props[:CODE_I].to_i &&
      feeder.school_name == props[:SCHOOL] &&
      feeder.district_name == props[:DISTRICT]
    end
    list.fetch(index, nil) unless index.nil?
  end

  def self.update_pattern(grade_level, feature, fp)
    geom = RGeo::GeoJSON.decode(feature[:geometry].to_json).as_text
    stash_failure(grade_level, feature[:geometry], fp, geom)

    if geom.nil? or geom.strip.empty?
      puts "WARNING: geom not parsed for #{fp.school_name} #{fp.code_c}"
    else
      fp.geom = geom
      if fp.save!
        puts "Saved #{fp.school_name} #{fp.code_c}"
        true
      else
        puts "WARNING: geom not saved for #{fp.school_name} #{fp.code_c}"
      end
    end
  end

  def self.stash_failure(grade_level, geometry, fp, geom)
    if DEBUGGING
      vertices = geometry[:coordinates].reduce(0) { |m, p| m + p.length }
      File.open(Rails.root.join('tmp', 'seeding', "feeder_pattern_#{grade_level}_#{fp.code_c}.dump"), 'wb') do |f|
        f.puts "#{fp.school_name} #{fp.district_name} #{fp.code_c} #{fp.dist_id} #{vertices}"
        f.puts "\n\n#{'*' * 40}\n"
        f.puts geometry.to_json
        f.puts "\n\n#{'*' * 40}\n"
        f.puts geom
      end
    end
  end
end
