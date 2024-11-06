class CreateMappingSnapshots < ActiveRecord::Migration[6.0]
  def change
    create_table "support.mapping_snapshots" do |t|
      t.jsonb :snapshot, default: {}, null: false
      t.timestamps
    end
  end
end
