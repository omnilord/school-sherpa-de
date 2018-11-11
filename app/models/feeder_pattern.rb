class FeederPattern < ApplicationRecord
  belongs_to :district
  belongs_to :school, optional: true

  scope :grade, ->(grade) { where(grade_level: grade.downcase) }
  scope :containing, ->(lat, lon) { where(Arel.sql("ST_intersects(feeder_patterns.geom, ST_POINT(#{lon.to_f}, #{lat.to_f}))")) }
  scope :no_geom, -> { select(column_names.map(&:to_sym).reject { |s| s == :geom }) }
end
