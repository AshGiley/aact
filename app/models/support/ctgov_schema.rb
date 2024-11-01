module Support
  class CtgovSchema  < ApplicationRecord
    self.table_name = "support.ctgov_schema"

    validates :table_name, :column_name, presence: true
  end
end