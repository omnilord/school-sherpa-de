require 'csv'

class SchoolDirectoryImporter
  SRC = Rails.root.join('db', 'seed_files', 'School_Directory.csv')
  HEADERS = {
    schoolyear: :year,
    districtcode: nil,
    schoolcode: :code,
    districtname: nil,
    districttype: nil,
    schoolname: :name,
    schooltype: :school_type,
    street1: :street1,
    street2: :street2,
    city: :city,
    state: :state,
    zip: :zip,
    county: :county,
    lowestgrade: :lowest_grade,
    highestgrade: :highest_grade,
    educationlevel: :education_level,
    hasec: :early_care,
    haspk: :pre_k,
    haskn: :kindergarten,
    haselementarygrade: :elementary,
    hasmiddlegrade: :middle,
    hashighgrade: :high,
    isungraded: :ungraded,
    #geocoded location: nil
  }
  BOOL_COLS = %i[hasec haspk haskn haselementarygrade hasmiddlegrade hashighgrade isungraged]

  def self.import(years = [DateTime.now.year])
    imported = 0

    CSV.foreach(SRC, headers: true, header_converters: :symbol) do |row|
      next unless years.include?(row[:schoolyear].to_i)

      data = HEADERS.map do |k, v|
        next if v.nil?
        [v, BOOL_COLS.include?(k) ? (row[k].to_i == 1) : row[k]]
      end

      if school = School.new(data.compact.to_h)
        imported += 1
        school.district = ensure_district(school,
                                          code: row[:districtcode].to_i,
                                          district_type: row[:districttype],
                                          name: row[:districtname])
        school.save
      end
    end

    puts "#{imported} Schools imported."
  end

  def self.ensure_district(school, **data)
    District.where(code: data[:code]).first_or_create do |d|
      d.attributes = data
    end
  end
end
