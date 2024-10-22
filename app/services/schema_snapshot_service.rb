class SchemaSnapshotService
  def initialize(schema_name)
    @schema_name = schema_name
    @current_schema_data = nil
  end

  def save_snapshot
    schema_data = current_schema_data
    snapshot = Support::SchemaSnapshot.new(schema_name: @schema_name, snapshot: schema_data)
    if snapshot.save
      puts "Schema snapshot saved for #{@schema_name}"
    else
      puts "Failed to save schema snapshot: #{snapshot.errors.full_messages.join(", ")}"
    end
  end

  
  def schema_changed?
    latest = Support::SchemaSnapshot.where(schema_name: @schema_name).last

    if latest.nil?
      puts "No previous snapshot found for #{@schema_name}"
      return false
    end

    current_data = current_schema_data

    if latest.snapshot == current_data
      puts "No schema changes detected for #{@schema_name}"
      return false
    else
      puts "Schema changes detected for #{@schema_name}!"
      return true
    end
  end

  # TODO: Review getting the exact schema changes

  private

  def current_schema_data
    @current_schema_data ||= ActiveRecord::Base.connection.select_all(<<-SQL).to_a
      SELECT table_name, column_name
      FROM information_schema.columns
      WHERE table_schema = '#{@schema_name}'
      ORDER BY table_name, ordinal_position;
    SQL
  end
end
