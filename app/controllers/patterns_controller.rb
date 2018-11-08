class PatternsController < ApplicationController
  def lookup
    @geo_params = params_for_grade
    @feeder_pattern = FeederPattern.includes(:school)
                      .containing(@geo_params[:lat], @geo_params[:lon])
                      .select { |pattern| pattern.school.grade?(@geo_params[:grade_level]) }
                      .first

    if @feeder_pattern.nil?
      return render json: nil, status: :not_found
    end
  end

private

  def params_for_grade
    unless School::GRADE_LEVELS.include?(params[:grade_level]&.downcase)
      gl = School::GRADE_LEVELS.join(', ')
      return render json: { error: "Acceptable grade_level values are: #{gl}" },
             status: :unprocessable_entity
    end

    coord_params.merge({ grade_level: params[:grade_level].downcase })
  end

  def coord_params
    if params[:lat].blank? || params[:lon].blank?
      return render json: { error: 'Both Latitude and Longitude must be supplied.' },
             status: :unprocessable_entity
    end

    {
      lat: params[:lat].to_f,
      lon: params[:lon].to_f
    }
  end
end
