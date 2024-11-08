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
    
    namespace :ctgov do
      desc "update current schema state"
      task process: :environment do
        Schema::CtgovService.new.process
        puts "ctgov schema state updated!"
      end
    end
  end
end