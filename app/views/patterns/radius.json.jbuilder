json.partial! 'app/geojson/feature_collection',
              locals: {
                features: @schools,
                feature_proc: lambda do |school|
                  json.partial! school
                end,
                props: lambda do
                  json.districts @districts do |district|
                    json.partial! district
                  end
                end
              }
