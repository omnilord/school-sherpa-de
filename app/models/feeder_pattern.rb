class FeederPattern < ApplicationRecord
  GRADE_LEVELS = %[kindergarten one two three four five six seven eight nine ten eleven twelve]
  belongs_to :district
  belongs_to :school, optional: true

  scope :grade, ->(grade) { where(grade_level: grade.downcase) }
  scope :containing, ->(lat, lon) { where(Arel.sql("ST_intersects(feeder_patterns.geom, ST_POINT(#{lon.to_f}, #{lat.to_f}))")) }
end
