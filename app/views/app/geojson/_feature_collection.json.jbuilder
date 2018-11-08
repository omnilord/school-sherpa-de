json.type "FeatureCollection"
json.features features do |fp|
  feature_proc.call(fp)
end
if props.respond_to?(:call)
  json.properties do
    props.call 
  end
end
