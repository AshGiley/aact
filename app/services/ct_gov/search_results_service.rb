module CTGov
  class SearchResultsService
    def initialize(api_client = CTGov::ApiClient::V2.new)
      unless api_client.is_a?(CTGov::ApiClient::Base)
        raise ArgumentError, "Invalid API client. Must inherit from CTGov::ApiClient::Base"
      end
      @api_client = api_client
    end

    def fetch_studies_for(search_term, group: nil, page_size: 1000)
      puts "Fetching search results for: #{search_term}"

      attributes = { term: search_term.downcase }
      attributes[:group] = group if group.present?
      search_term_record = SearchTerm.find_by(term: attributes[:term]) || SearchTerm.create!(attributes)

      @api_client.search_studies(query: search_term, page_size: page_size) do |studies|
        persist(studies, search_term_record)
      end
    end

    def refresh_search_results_for(group)
      raise ArgumentError, "Group parameter is required" if group.blank?

      terms = SearchTerm.where(group: group.downcase)
      Rails.logger.info("Refreshing #{terms.count} terms for group: #{group}")

      terms.each do |term|
        fetch_studies_for(term.term, group: term.group)
      end

    end

    private

    def persist(studies, search_term)
      silence_active_record do
        nct_ids = studies.map { |study| study.dig(*@api_client.nct_id_path) }.compact
        valid_nct_ids = Study.where(nct_id: nct_ids).pluck(:nct_id)

        study_results = valid_nct_ids.map do |nct_id|
          {
            nct_id: nct_id,
            search_term_id: search_term.id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        # current logic: remove all existing search results for the term and insert fresh results
        ActiveRecord::Base.transaction do
          SearchTermResult.where(search_term_id: search_term.id).delete_all
          return if study_results.empty?
          SearchTermResult.insert_all(study_results)
        end

        Rails.logger.info("Imported #{study_results.size} search results for term: #{search_term.term}")
      end
    rescue => e
      Rails.logger.error("Error persisting search results: #{e.message}")
      raise
    end
  end

end