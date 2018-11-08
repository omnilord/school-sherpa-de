json.name district.name
json.address district.address
json.administrator do
  if district.administrator.nil?
    nil
  else
    json.name district.administrator
    json.title district.administrator_title
  end
end
json.coordinates [
  district.lon,
  district.lat
]
