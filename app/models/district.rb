class District < ApplicationRecord
  has_many :feeder_pattern
  has_many :schools
end
