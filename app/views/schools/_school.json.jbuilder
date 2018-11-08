json.name school.name
json.address school.address
json.grades = school.grades
json.coordinates [
  school.lon,
  school.lat
]
json.district do
  json.partial! school.district
end
