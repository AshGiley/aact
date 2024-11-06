module Support
  class MappingSnapshot < ApplicationRecord
    self.table_name = "support.mapping_snapshots"
    validates :snapshot, presence: true

    def self.latest_snapshot
      order(created_at: :desc).first&.snapshot
    end
  end
end