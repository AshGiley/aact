namespace :db do
  task :snapshot, [:force] => :environment do |t, params|
    Util::Updater.new.take_snapshot
  end
end


namespace :schema do
  desc "Get the schema snapshot, compare with the latest snapshot, and save a new snapshot if changes are detected"
  task :snapshot, [:schema_name] => :environment do |_t, args|
    schema_name = args[:schema_name] || "ctgov"
    service = SchemaSnapshotService.new(schema_name)
    service.save_snapshot if service.schema_changed?
  end
end