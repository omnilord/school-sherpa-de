json.type 'Feature'
json.geometry @raw_geojson
json.properties do
  json.partial! @district
end
