module Support
  class CtgovMetadataSnapshot < ApplicationRecord
    self.table_name = "support.ctgov_metadata_snapshots"

    validates :api_version, presence: true
    validates :snapshot, presence: true


    def self.latest_snapshot_for(api_version)
      where(api_version: api_version)
        .order(created_at: :desc)
        .first&.snapshot
    end
  end
end