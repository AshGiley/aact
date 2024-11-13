module Support
  class CtgovMapping < ApplicationRecord
    self.table_name = "support.ctgov_mapping"

    validates :table_name, :field_name, :api_path, presence: true
  end
end
