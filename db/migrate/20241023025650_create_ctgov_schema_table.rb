class CreateCtgovSchemaTable < ActiveRecord::Migration[6.0]
  def change
    create_table "support.ctgov_schema" do |t|
      t.boolean :active, default: true, null: false
      t.string :table_name, null: false
      t.string :column_name, null: false
      t.string :data_type, null: false
      # t.boolean :nullable, default: true, null: false
      t.string :description, null: true

      t.timestamps
    end

    add_index :ctgov_schema, [:table_name, :column_name], unique: true, name: 'index_ctgov_documentation_on_table_and_column'
  end
end
