class PatternsController < ApplicationController
  def lookup
    unless School::GRADE_LEVELS.include?(params[:grade_level]&.downcase)
      gl = School::GRADE_LEVELS.join(', ')
      return render json: { error: "Acceptable grade_level values are: #{gl}" },
             status: :unprocessable_entity
    end
    if params[:lat].blank? || params[:lon].blank?
      return render json: { error: 'Both Latitude and Longitude must be supplied.' },
             status: :unprocessable_entity
    end

    @feeder_pattern = FeederPattern.includes(:school)
                      .containing(params[:lat].to_f, params[:lon].to_f)
                      .select { |pattern| pattern.school.grade?(params[:grade_level].downcase) }
                      .first
  end
end
