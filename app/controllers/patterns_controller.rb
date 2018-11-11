class PatternsController < ApplicationController
  def lookup
    @geo_params = params_for_grade
    @feeder_patterns = FeederPattern.no_geom.includes(:school)
                       .containing(@geo_params[:lat], @geo_params[:lon])

    unless @geo_params[:grade_level] == 'all'
      @feeder_patterns = @feeder_patterns.select { |pattern| pattern.school.grade?(@geo_params[:grade_level]) }
    end

    if @feeder_patterns.nil? || @feeder_patterns.length == 0
      return render json: nil, status: :not_found
    else
      @districts = @feeder_patterns.map { |fp| fp.school.district }.uniq
    end
  end

  def radius
    @geo_params = params_for_radius
    @schools = School.no_geom.within_radius(@geo_params[:lat].to_f,
                                            @geo_params[:lon].to_f,
                                            @geo_params[:radius])

    if @schools.nil? || @schools.length == 0
      return render json: nil, status: :not_found
    else
      @districts = @schools.map(&:district).uniq
    end
  end

  def district
    @geo_params = coord_params
    @district = District.within_radius(@geo_params[:lat].to_f,
                                       @geo_params[:lon].to_f)

    if @district.nil? || @district.length == 0
      return render json: nil, status: :not_found
    end
  end

private

  def params_for_grade
    allowed_grades = School::GRADE_KEYS + ['all']
    unless allowed_grades.include?(params[:grade_level]&.downcase)
      gl = School::GRADE_KEYS.join(', ')
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
