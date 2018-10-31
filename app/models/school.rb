class School < ApplicationRecord
  belongs_to :district, optional: true
  has_many :feeder_patterns

  GRADE_KEYS = %w[earlychildhood prekindergarten kindergarten one two three four five six seven eight nine ten eleven twelve].freeze
  GRADE_NAMES = [
    'Early Childhood', 'Pre-Kindergarten', 'Kindergarten',
    'First Grade', 'Second Grade', 'Third Grade', 'Fourth Grade',
    'Fifth Grade', 'Sixth Grade', 'Seventh Grade', 'Eighth Grade',
    'Ninth Grade (Freshman)', 'Tenth Grade (Sophomore)',
    'Eleventh Grade (Junior)', 'Twelfth Grade (Senior)'
  ].freeze
  GRADE_LEVELS = GRADE_KEYS.zip(GRADE_NAMES).to_h.freeze

  def lowest_grade_numeric
    @lowest_grade_numeric ||=
      case lowest_grade
      when 'PR' then -2
      when 'PK' then -1
      when 'KG' then 0
      else
        lowest_grade.to_i
      end
  end

  def highest_grade_numeric
    @highest_grade_numeric ||=
      case highest_grade
      when 'PR' then -2
      when 'PK' then -1
      when 'KG' then 0
      else
        highest_grade.to_i
      end
  end

  def grade?(grade_level)
    grade_n = GRADE_KEYS.find_index(grade_level) - 2
    (lowest_grade_numeric..highest_grade_numeric).include?(grade_n)
  end

  def grades
    (lowest_grade_numeric..highest_grade_numeric).map do |n|
      [GRADE_KEYS[n], GRADE_NAMES[n]]
    end
  end

  def address
    [street1, street2, city, state, zip].compact.join(', ')
  end
end
