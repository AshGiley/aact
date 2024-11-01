class SchemaSyncService
  def initialize(schema_name)
    @schema_name = schema_name
  end

  def sync_schema_with_documentation
    schema_snapshot = fetch_schema_snapshot

    schema_snapshot.each do |item|
      table_name = item['table_name']
      column_name = item['column_name']
      doc_record = find_or_initialize_documentation(table_name, column_name)
      doc_record.data_type = item['data_type'] # TODO: normalize data type
      doc_record.save!
    end

    # TODO: add inactive records that not present in the shema snapshot
  end

  private

  def fetch_schema_snapshot
    # TODO: optimize using scope - fetch latest snapshot
    Support::SchemaSnapshot.where(schema_name: @schema_name).order(created_at: :desc).first.snapshot
  end

  def find_or_initialize_documentation(table_name, column_name)
    Support::CtgovSchema.find_or_initialize_by(table_name: table_name, column_name: column_name)
  end
end