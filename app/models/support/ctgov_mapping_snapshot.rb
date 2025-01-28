module Support
  class CtgovMappingSnapshot < ApplicationRecord
    self.table_name = "support.ctgov_mapping_snapshots"
    validates :snapshot, presence: true

    def self.latest_snapshot
      order(created_at: :desc).first&.snapshot
    end
  end
end