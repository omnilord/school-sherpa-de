class School < ApplicationRecord
  belongs_to :district, optional: true
  has_many :feeder_patterns
end
