class District < ApplicationRecord
  include Geocodable

  has_many :feeder_pattern
  has_many :schools

  scope :no_geom, -> { select(column_names.map(&:to_sym).reject { |s| s == :geom }) }
  scope :containing, ->(lat, lon) { where(Arel.sql("ST_intersects(districts.geom, ST_POINT(#{lon.to_f}, #{lat.to_f}))")) }

  def self.raw_geom(id)
    sql = <<~SQL
      SELECT ST_AsGeoJSON(geom::geometry) geom_json
      FROM districts
      WHERE id = #{id.to_i}
    SQL
    ActiveRecord::Base.connection.execute(sql).first['geom_json']
  end
end
