Blueprinter.configure do |config|
  config.generator = Yajl::Encoder
  config.method = :encode
  config.sort_fields_by = :definition
  config.association_default = {}
end