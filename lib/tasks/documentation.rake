namespace :docs do

  namespace :metadata do
    desc "Process CTGov API metadata"
    task process: :environment do
      CTGov::MetadataService.new.process
      puts "Completed!"
    end
  end
  

  namespace :mapping do
    desc "Take mapping snapshot and update current state"
    task process: :environment do
      MappingService.new.process
      puts "Completed!"
    end
  end


  # rename if schema is passed as argument
  namespace :ctgov_schema do
    desc "update current schema state"
    task process: :environment do
      SchemaService.new.process
      puts "Completed!"
    end
  end
end