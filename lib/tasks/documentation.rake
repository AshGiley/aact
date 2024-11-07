namespace :docs do

  namespace :metadata do
    desc "Process CTGov API metadata"
    task process: :environment do
      CTGov::MetadataService.new.process
      puts "Metadata Processed!"
    end
  end
  
  
  namespace :mapping do
    desc "Take mapping snapshot and update current state"
    task process: :environment do
      DataMappingService.new.process
      puts "Mapping Processed!"
    end
  end


  namespace :schema do
    
    desc "Get the schema snapshot, compare with the latest snapshot, and save a new snapshot if changes are detected"
    task :snapshot, [:schema_name] => :environment do |_t, args|
      schema_name = args[:schema_name] || "ctgov"
      service = SchemaSnapshotService.new(schema_name)
      service.save_snapshot if service.schema_changed?
    end
    
    desc "take snapshot of the schema and update current state"
    task :process, [:schema_name] => :environment do |_t, args|
      schema_name = args[:schema_name] || "ctgov"
      SchemaSyncService.new(schema_name).process
    end
  end
end