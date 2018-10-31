json.type 'Feature'
json.geometry do
  json.type 'Point'
  json.coordinates @feeder_pattern.school.coords
end
json.properties do
  json.school do
    json.name @feeder_pattern.school.name
    json.address @feeder_pattern.school.address
    json.grades = @feeder_pattern.school.grades
  end
  json.district do
    json.name @feeder_pattern.district.name
    json.address @feeder_pattern.district.address
  end
end
