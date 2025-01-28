class CreateSettingsTable < ActiveRecord::Migration[6.0]
  def up
    create_table "support.settings" do |t|
      t.string :key, null: false, index: { unique: true }
      t.text :value, null: false
      t.timestamps
    end

    execute("INSERT INTO settings (key, value, created_at, updated_at) VALUES ('export_search_results', 'false', NOW(), NOW())")
  end

  def down
    drop_table :settings
  end
end
