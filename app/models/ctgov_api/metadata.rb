module CtgovApi
  class Metadata < ApplicationRecord
    self.table_name = "support.ctgov_metadata"

    # TODO: Add active flag - to handle changes coming from the API

    validates :name, :data_type, :path, :version, presence: true
  end
end
# TODO: move to support namespace for consistency