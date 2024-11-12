module Support
  class CtgovSchemaSnapshot < ApplicationRecord
    self.table_name = "support.ctgov_schema_snapshots"

    validates :schema_name, presence: true
    validates :snapshot, presence: true

    def self.latest_snapshot_for(schema)
      where(schema_name: schema)
        .order(created_at: :desc)
        .first&.snapshot
    end
  end
end