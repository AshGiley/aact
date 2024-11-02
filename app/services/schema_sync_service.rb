class SchemaSyncService
  def initialize(schema_name)
    @schema_name = schema_name
  end

  def sync_schema_with_latest_snapshot
    schema_snapshot = fetch_schema_snapshot

    snapshot_hash = prepare_snapshot(schema_snapshot)

    schema_records.each do |record|
      key = [record.table_name, record.column_name]
      if snapshot_hash.key?(key)
        record.update!(
          data_type: snapshot_hash[key]["data_type"],
          active: true
        )
      snapshot_hash.delete(key)
      else
        puts "Marking #{record.table_name}.#{record.column_name} as inactive"
        record.update!(active: false) # if not a part of the snapshot, mark as inactive
      end
    end

    snapshot_hash.each_value do |item|
      Support::CtgovSchema.create!(
        table_name: item["table_name"],
        column_name: item["column_name"],
        data_type: item["data_type"],
        active: true
      )
    end
    # TODO: add is nullable?
  end

  private

  def fetch_schema_snapshot
    # TODO: optimize using scope - fetch latest snapshot
    Support::SchemaSnapshot.where(schema_name: @schema_name).order(created_at: :desc).first.snapshot
  end

  def schema_records
    # TODO: link passed schema to the model used to retrieve the schema values
    Support::CtgovSchema.all # for not is okay since only one schema is used
  end

  # convert snapshot to hash for easy access by table_name and column_name
  def prepare_snapshot(snapshot)
    snapshot.each_with_object({}) do |item, hash|
      key = [item["table_name"], item["column_name"]]
      hash[key] = item
    end
  end
end