module CtgovApi
  class Mapping < ApplicationRecord
    self.table_name = "support.ctgov_mappings"

    validates :table_name, :field_name, :api_path, presence: true
  end
end
# TODO: move to support namespace for consistency