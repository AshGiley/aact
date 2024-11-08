module CTGov
  class SchemaService
    def initialize
      @schema = "ctgov"
      @snapshot = nil
    end


    def process
      
      take_snapshot
      # TODO: handle case when snapshot is nil

      # puts @snapshot

      if schema_changed?
        puts "Schema changed"
        ActiveRecord::Base.transaction do
          # save snapshot
          Support::SchemaSnapshot.create!(schema_name: @schema, snapshot: @snapshot)
          
          # update current state
          sync_schema_with_latest_snapshot

        end
      else
        puts "No changes detected in schema"
      end
    end

    def sync_schema_with_latest_snapshot
      # schema_snapshot = fetch_schema_snapshot

      snapshot_hash = prepare_snapshot(@snapshot)
      records_to_delete = []

      schema_records.each do |record|
        key = [record.table_name, record.column_name]
        if snapshot_hash.key?(key)
          record.update!(
            data_type: snapshot_hash[key]["data_type"],
            nullable: snapshot_hash[key]["is_nullable"], # handle YES/NO to true/false
          )
        snapshot_hash.delete(key)
        else
          puts "Removing #{record.table_name}.#{record.column_name}"
          records_to_delete << record.id
        end
      end

      Support::CtgovSchema.where(id: records_to_delete).delete_all

      new_records = snapshot_hash.values.map do |item|
        Support::CtgovSchema.new(
          table_name: item["table_name"],
          column_name: item["column_name"],
          data_type: item["data_type"],
          nullable: item["is_nullable"] == "YES"
        )
      end

      Support::CtgovSchema.import(new_records)
    end

    # private

    def schema_records
      # TODO: link passed schema to the model used to retrieve the schema values
      Support::CtgovSchema.all
    end

    # convert snapshot to hash for easy access by table_name and column_name
    def prepare_snapshot(snapshot)
      snapshot.each_with_object({}) do |item, hash|
        key = [item["table_name"], item["column_name"]]
        hash[key] = item
      end
    end

    def take_snapshot
      @snapshot ||= ActiveRecord::Base.connection.select_all(<<-SQL).to_a
        SELECT c.table_name, c.column_name, c.data_type, c.is_nullable
        FROM information_schema.columns c
        JOIN information_schema.tables t 
          ON c.table_name = t.table_name
          AND c.table_schema = t.table_schema
        WHERE c.table_schema = '#{@schema}' AND t.table_type = 'BASE TABLE'
        ORDER BY c.table_name, c.ordinal_position;
        --LIMIT 50;
      SQL

    end

    def schema_changed?
      latest = Support::SchemaSnapshot.latest_snapshot_for(@schema)
      return true if latest.nil?
      latest != @snapshot
    end


    def process_schema
      put "Processing schema"
    end
  end
end