class SchemaSnapshotHandler

  def initialize(schema)
    @schema = schema
  end


  def take_snapshot
    schema_data = ActiveRecord::Base.connection.select_all(<<-SQL).to_a
      SELECT c.table_name, c.column_name, c.data_type, c.is_nullable
      FROM information_schema.columns c
      JOIN information_schema.tables t 
        ON c.table_name = t.table_name
        AND c.table_schema = t.table_schema
      WHERE c.table_schema = '#{@schema}' AND t.table_type = 'BASE TABLE'
      ORDER BY c.table_name, c.ordinal_position;
    SQL

    schema_data.each_with_object({}) do |item, hash|
      key = "#{item["table_name"]}.#{item["column_name"]}"
      hash[key] = item
    end
  rescue StandardError => e
    Rails.logger.error("Error taking snapshot: #{e.message}")
    nil
  end


  def latest_snapshot
    Support::CtgovSchemaSnapshot.latest_snapshot_for(@schema)
  end


  def save_snapshot(snapshot)
    Support::CtgovSchemaSnapshot.create!(schema_name: @schema, snapshot: snapshot)
  end


  def snapshot_changed?(current_snapshot)
    latest = latest_snapshot
    return true if latest.nil?
    latest != current_snapshot
  end
end