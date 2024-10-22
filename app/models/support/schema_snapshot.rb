module Support
  class SchemaSnapshot < ApplicationRecord
    self.table_name = "support.schema_snapshots"

    validates :schema_name, presence: true
    validates :snapshot, presence: true
  end
end