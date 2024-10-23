module CtgovApi
  class Documentation < ApplicationRecord
    self.table_name = "support.ctgov_documentation"

    belongs_to :ctgov_metadata, optional: true, foreign_key: "ctgov_metadata_id"
    belongs_to :ctgov_mappings, optional: true, foreign_key: "ctgov_mapping_id"

    validates :table_name, :column_name, presence: true
  end
end