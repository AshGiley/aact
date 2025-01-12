module CTGov
  class SearchResultsService
    def initialize(api_client = CTGov::ApiClient::V2.new)
      unless api_client.is_a?(CTGov::ApiClient::Base)
        raise ArgumentError, "Invalid API client. Must inherit from CTGov::ApiClient::Base"
      end
      @api_client = api_client
    end


    # TODO: pass group instead of category
    def fetch_studies_for(search_term, group: "other", page_size: 1000)
      puts "Fetching search results for: #{search_term}"

      search_term_record = SearchTerm.find_or_create_by!(term: search_term, group: group)


      @api_client.search_studies(query: search_term, page_size: page_size) do |studies|
        persist(studies, search_term_record)
      end

      # STEPS TO COMPLETE
      # call api client method to search results
      # process results
      # save results to database -> migration + models
        # how to handle records for removed or jonied studies?
      # create rake task to run this service
      # add functionality to the admin website
    end



    private

    def persist(studies, search_term)
      silence_active_record do
        #  Get existing nct_ids from studies table
        existing_nct_ids = Study.pluck(:nct_id).to_set

        study_results = studies.map do |study|
          # temp logic to handle missing nct_ids
          nct_id = study.dig(*@api_client.nct_id_path)
          next unless nct_id && existing_nct_ids.include?(nct_id)
          {
            nct_id: nct_id,
            search_term_id: search_term.id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end.compact # Remove any nil nct_ids

        SearchTermResult.import(
          study_results,
          on_duplicate_key_update: {
            conflict_target: [:nct_id, :search_term_id],
            columns: [:updated_at]
          }
        )

        Rails.logger.info("Imported #{study_results.size} search results for term: #{search_term.term}")
        puts "Imported #{study_results.size} search results"
      end
    rescue => e
      Rails.logger.error("Error persisting search results: #{e.message}")
      raise
    end
  end

end