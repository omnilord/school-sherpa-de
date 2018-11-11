class District < ApplicationRecord
  include Geocodable

  has_many :feeder_pattern
  has_many :schools

  scope :no_geom, -> { select(column_names.map(&:to_sym).reject { |s| s == :geom }) }
end
