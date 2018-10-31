class District < ApplicationRecord
  include Geocodable

  has_many :feeder_pattern
  has_many :schools
end
