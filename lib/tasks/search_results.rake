# require_relative 'application_record'
require_relative '../../app/models/search_term_result'

namespace :search_results do
  desc 'Fetch and persist studies for a search term'
  task :fetch, [:term, :group] => :environment do |t, args|
    fail "Term is required. Group is optional" unless args[:term]

    service = CTGov::SearchResultsService.new
    begin
      service.fetch_studies_for(args[:term], group: args[:group])
      puts "✅ Successfully fetched studies for term: #{args[:term]}"
    rescue => e
      puts "❌ Error fetching studies: #{e.message}"
      raise e
    end
  end

  desc 'Refresh search results for a group'
  task :refresh, [:group] => :environment do |t, args|
    fail "Group is required" unless args[:group]

    service = CTGov::SearchResultsService.new
    begin
      service.refresh_search_results_for(args[:group])
      puts "✅ Successfully refreshed search results for group: #{args[:group]}"
    rescue => e  
      puts "❌ Error refreshing search results: #{e.message}"
      raise e
    end
  end
end