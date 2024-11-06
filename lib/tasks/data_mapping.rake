namespace :data_mapping do
  desc "Process mapping snapshot using Mapping Service"

  task process: :environment do
    DataMappingService.new.process
    puts "Mapping Processed!"
  end
end
