require 'json'
require 'rgeo/geo_json'
require 'fileutils'

SRC = "#{File.expand_path(File.dirname(__FILE__))}/../db/seed_files/Grade_*.geojson"
DIST_DIR = "#{File.expand_path(File.dirname(__FILE__))}/../db/seed_files/districts/%{DIST_ID}-%{DISTRICT}"

districts = {
  # 'district_id' => Filehandle
}

puts "#{SRC}\n#{DIST_DIR}"

Dir[SRC].each do |path|
  grade = File.basename(path, '.geojson')[6..-1].downcase
  puts "starting import for grade #{grade}"

  geodata = JSON.parse(File.read(path), symbolize_names: true)

  geodata[:features].each do |feature|
    props = feature[:properties]
    filekey = "#{props[:DIST_ID]}-#{grade}"

    dirpath = format(DIST_DIR, props)
    unless Dir.exist?(dirpath)
      puts "Create #{dirpath}"
      FileUtils.mkdir_p("#{dirpath}/schools")
    end

    unless districts.key?(filekey)
      filepath = "#{dirpath}/#{grade}.geojson"
      puts "Open #{filepath}"
      districts[filekey] = File.open(filepath, 'w') 
      districts[filekey].write '{"type":"FeatureCollection","features":['
      districts[filekey].write "\n"
    end

    puts "Saving #{props[:SCHOOL]}(#{props[:CODE_C]}) to #{props[:DISTRICT]}(#{props[:DIST_ID]})"
    districts[filekey].write feature.to_json
    districts[filekey].write "\n"

    school_path = "#{dirpath}/schools/#{props[:SCHOOL]}-#{props[:CODE_C]}.geojson"
    File.open(school_path, 'w') do |f|
      f.write feature.to_json
    end
  end
end

districts.values.each do |fh|
  fh.write "]}\n"
end
