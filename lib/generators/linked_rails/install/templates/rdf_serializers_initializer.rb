# frozen_string_literal: true

RDF::Serializers.configure do |config|
  config.default_graph = Vocab.ld[:supplant]
end
