require 'csv'

class DistrictsImporter
  SRC = Rails.root.join('db', 'seed_files', 'School_Districts_Boundaries.csv')
  HEADERS = {
    objectid: nil,
    name: :name,
    dist_id: :code,
    sqmiles: nil,
    shortname: :shortname,
    address: :address,
    admin: :administrator,
    title: :administrator_title,
    enroll: :students_enrolled,
    officecode: :office_code,
    web_url: :profile_url,
    dist_urL: :website_url,
    unified: nil,
    shape: nil,
    shapearea: nil,
    shapelen: nil
  }

  def self.import
    imported = 0

    CSV.foreach(SRC, headers: true, header_converters: :symbol) do |row|
      data = HEADERS.map do |k, v|
        next if v.nil?
        [v, row[k]]
      end

      imported += 1 if District.create!(data.compact.to_h)
    rescue ActiveRecord::RecordNotUnique
      # TODO: Something about updating the geometry?
    end

    puts "#{imported} Districts imported."
  end
end
