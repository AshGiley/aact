module Support
  class CtgovMetadata < ApplicationRecord
    self.table_name = "support.ctgov_metadata"

    # TODO: Add active flag - to handle changes coming from the API

    validates :name, :data_type, :path, presence: true
    validates :path, uniqueness: true
  end
end