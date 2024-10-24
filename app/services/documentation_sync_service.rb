class DocumentationSyncService
  def initialize(schema_name)
    @schema_name = schema_name
  end

  def sync_schema_with_documentation
    schema_snapshot = fetch_schema_snapshot

    schema_snapshot.each do |item|
      table_name = item['table_name']
      column_name = item['column_name']

      doc_record = find_or_initialize_documentation(table_name, column_name)
      # byebug
      mapping = CtgovApi::Mapping.find_by(table_name: table_name, field_name: column_name)
      doc_record.ctgov_mapping_id = mapping&.id

      if mapping
        doc_record.ctgov_mapping_id = mapping.id

        metadata = CtgovApi::Metadata.find_by(path: mapping.api_path)
        doc_record.ctgov_metadata_id = metadata&.id
      end

      doc_record.active = true
      doc_record.save!
    end

    # TODO: add inactive records that not present in the shema snapshot
  end

  # private

  def fetch_schema_snapshot
    # TODO: optimize using scope
    Support::SchemaSnapshot.where(schema_name: @schema_name).order(created_at: :desc).first.snapshot
  end

  def find_or_initialize_documentation(table_name, column_name)
    CtgovApi::Documentation.find_or_initialize_by(table_name: table_name, column_name: column_name)
  end
end