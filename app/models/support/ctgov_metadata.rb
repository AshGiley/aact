module Support
  class CtgovMetadata < ApplicationRecord
    self.table_name = "support.ctgov_metadata"

    validates :name, :data_type, :path, presence: true
    validates :path, uniqueness: true
  end
end