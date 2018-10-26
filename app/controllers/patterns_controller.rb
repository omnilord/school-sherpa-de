class PatternsController < ApplicationController
  def lookup
    unless FeederPattern::GRADE_LEVELS.include?(params[:grade_level]&.downcase)
      gl = FeederPattern::GRADE_LEVELS.join(', ')
      render json: { error: "Acceptable grade_level values are: #{gl}" },
             status: :unprocessable_entity
    end
    if params[:lat].blank? || params[:lon].blank?
      render json: { error: 'Both Latitude and Longitude must be supplied.' },
             status: :unprocessable_entity
    end

    feeder_school = FeederPattern.grade(params[:grade_level].downcase)
                           .containing(params[:lat].to_f, params[:lon].to_f)
                           .map { |fp| { school: fp.school.name,
                                         district: fp.district.name } }
    
    # TODO: return GeoJSON here
    render json: feeder_school.first
  end
end
