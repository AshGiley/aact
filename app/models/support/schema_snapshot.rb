module Support
  class SchemaSnapshot < ApplicationRecord
    self.table_name = "support.schema_snapshots"

    validates :schema_name, presence: true
    validates :snapshot, presence: true

    def self.latest_snapshot_for(schema)
      where(schema_name: schema)
        .order(created_at: :desc)
        .first&.snapshot
    end
  end
end