class CreateCtgovDocumentationTable < ActiveRecord::Migration[6.0]
  def change
    create_table "support.ctgov_documentation" do |t|
      t.boolean :active, default: true
      t.string :table_name, null: false
      t.string :column_name, null: false
      t.string :data_type, null: true
      t.string :description, null: true

      t.references :ctgov_metadata, foreign_key: { to_table: "support.ctgov_metadata" }, null: true
      t.references :ctgov_mapping, foreign_key: { to_table: "support.ctgov_mappings" }, null: true

      t.timestamps
    end

    add_index :ctgov_documentation, [:table_name, :column_name], unique: true, name: 'index_ctgov_documentation_on_table_and_column'
  end
end
