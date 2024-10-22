class CreateSchemaSnapshots < ActiveRecord::Migration[6.0]
  def change
    create_table "support.schema_snapshots" do |t|
      t.string :schema_name, null: false
      t.jsonb :snapshot, default: {}, null: false
      t.timestamps
    end
  end
end
