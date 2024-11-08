module Support
  class CtgovSchema  < ApplicationRecord
    self.table_name = "support.ctgov_schema"

    validates :table_name, :column_name, :active, :data_type, presence: true
    validates :nullable, inclusion: { in: [true, false] }

  end
end