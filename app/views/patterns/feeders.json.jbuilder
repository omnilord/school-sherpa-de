json.partial! 'app/geojson/feature_collection',
              locals: {
                features: @feeder_patterns,
                feature_proc: lambda do |fp|
                  json.partial! 'app/geojson/features/point',
                                locals: {
                                  propname: 'school',
                                  feature: fp.school,
                                  coordinates: [
                                    fp.school.lon,
                                    fp.school.lat
                                  ]
                                }
                end,
                props: lambda do
                  json.districts @districts do |district|
                    json.partial! district
                  end
                end
              }
