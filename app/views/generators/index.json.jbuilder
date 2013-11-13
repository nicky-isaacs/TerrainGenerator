json.array!(@generators) do |generator|
  json.extract! generator, :name
  json.url generator_url(generator, format: :json)
end
