json.partial! 'app/geojson/feature_collection',
              locals: {
                features: @schools,
                feature_proc: lambda do |school|
                  json.partial! 'app/geojson/features/point',
                                locals: {
                                  propname: 'school',
                                  feature: school,
                                  coordinates: [
                                    school.lon,
                                    school.lat
                                  ]
                                }
                end,
                props: lambda do
                  json.districts @districts do |district|
                    json.partial! district
                  end
                end
              }
