json.partial! 'app/geojson/features/point',
              locals: {
                propname: 'school',
                feature: @feeder_pattern.school,
                coordinates: [
                  @feeder_pattern.school.lon,
                  @feeder_pattern.school.lat
                ]
              }
