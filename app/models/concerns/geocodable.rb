module Geocodable
  extend ActiveSupport::Concern

  #
  # Geocoable Concern
  #
  # Adds geocoding to the model so that it can be managed appropriately.

  included do
    #set_rgeo_factory_for_column(:coords, RGeo::Geographic.spherical_factory(:srid => 4326))

    geocoded_by :address do |obj, results|
      if geo = results.first
        obj.coords = "POINT(#{geo.longitude.to_f} #{geo.latitude.to_f})"
      end
    end
  end

  def geocode!
    unless geocoded?
      puts "Geocoding: #{name}"
      geocode
      save if changed?
    end
  end

  def latitude
    coords&.lat
  end
  alias_method :lat, :latitude

  def latitude=(value)
    coords = "POINT(#{longitude} #{value.to_f})"
  end
  alias_method :lat=, :latitude=

  def longitude
    coords&.lon
  end
  alias_method :lon, :longitude

  def longitude=(value)
    coords = "POINT(#{value.to_f} #{latitude})"
  end
  alias_method :lon=, :longitude=
end
