class CreateSnapshotTables < ActiveRecord::Migration[6.0]
  def change
    create_table "support.ctgov_mapping_snapshots" do |t|
      t.jsonb :snapshot, default: {}, null: false
      t.timestamps
    end

    create_table "support.ctgov_schema_snapshots" do |t|
      t.string :schema_name, null: false
      t.jsonb :snapshot, default: {}, null: false
      t.timestamps
    end

    create_table "support.ctgov_metadata_snapshots" do |t|
      t.string :api_version, null: false
      t.jsonb :snapshot, default: {}, null: false
      t.timestamps
    end
  end
end
