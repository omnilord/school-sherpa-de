json.type 'Feature'
json.geometry do
  json.type 'MultiPolygon'
  json.coordinates geom
end
json.properties do
  if defined?(propname)
    json.set! propname do
      json.partial! feature
      props.call if defined?(props) && props.respond_to?(:call)
    end
  end
end
