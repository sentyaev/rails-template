module Searchable
    extend ActiveSupport::Concern
  
    included do
        include Elasticsearch::Model
        include Elasticsearch::Model::Callbacks

        # index name will depend on the environment
        index_name [Rails.env, model_name.collection.underscore].join('_')

        # mapping do
        #     # mapping definition goes here
        # end

        # def self.search(query)
        #     # build and run search
        # end
    end
end