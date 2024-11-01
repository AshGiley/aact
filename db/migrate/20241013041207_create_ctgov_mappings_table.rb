class CreateCtgovMappingsTable < ActiveRecord::Migration[6.0]

  def change
    create_table "support.ctgov_mappings" do |t|
      t.boolean :active, default: true
      t.string :table_name
      t.string :field_name
      t.string :api_path
      t.timestamps
    end

    add_index "support.ctgov_mappings", [ :table_name, :field_name, :api_path ], unique: true, name: "index_ctgov_mappings_on_table_field_api_path"
  end
end
