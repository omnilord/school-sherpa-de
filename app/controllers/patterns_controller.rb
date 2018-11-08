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

  def radius
    @geo_params = params_for_radius
    @schools = School.within_radius(@geo_params[:lat].to_f,
                                    @geo_params[:lon].to_f,
                                    @geo_params[:radius])

    if @schools.nil?
      return render json: nil, status: :not_found
    else
      @districts = @schools.map(&:district).uniq
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

  def params_for_radius
    unless params[:radius].present? && params[:radius].to_f > 0.0
      return render json: { error: 'Radius should be a positive, numeric value,' },
             status: :unprocessable_entity
    end

    coord_params.merge({ radius: params[:radius].to_f })
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
