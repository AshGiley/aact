class SchemaService

  # TODO: ducouple schema model from the service
  def initialize
    @schema = "ctgov"
    @snapshot_handler = SchemaSnapshotHandler.new(@schema)
  end

  def process
    snapshot = @snapshot_handler.take_snapshot
    if snapshot.nil?
      Rails.logger.error("Failed to retrieve snapshot for schema: #{@schema}")
      return # raise error?
    end

    unless @snapshot_handler.snapshot_changed?(snapshot)
      puts "No changes detected in schema"
      return
    end

    
    ActiveRecord::Base.transaction do
      puts "Schema changed"
      @snapshot_handler.save_snapshot(snapshot)
      sync_schema_with_snapshot(snapshot)
    end
  end

  private


  def sync_schema_with_snapshot(snapshot)
    records_to_delete = []

    schema_records.each do |record|
      # to match the key in the snapshot
      key = "#{record["table_name"]}.#{record["column_name"]}"
      if snapshot.key?(key)
        update_record(record, snapshot[key]) # TODO: update by bulk?
        snapshot.delete(key)
      else
        records_to_delete << record.id
      end
    end

    delete_obsolete_records(records_to_delete)
    create_new_records(snapshot.values)
  end


  def schema_records
    Support::CtgovSchema.all
  end


  def delete_obsolete_records(ids)
    Support::CtgovSchema.where(id: ids).delete_all if ids.any?
  end


  # TODO: move to model?
  def create_new_records(new_data)
    new_records = new_data.map do |data|
      # TODO: move to model?
      Support::CtgovSchema.new(
        table_name: data["table_name"],
        column_name: data["column_name"],
        data_type: data["data_type"],
        nullable: data["is_nullable"] == "YES"
      )
    end
    Support::CtgovSchema.import(new_records) if new_records.any?
  end


  # TODO: move to model? 
  # TODO: check for changes before updating?
  def update_record(record, snapshot_data)
    record.update!(
      data_type: snapshot_data["data_type"],
      nullable: snapshot_data["is_nullable"] == "YES"
    )
  end
end
