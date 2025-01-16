class SearchTermResult < ActiveRecord::Base
  self.table_name = "ctgov.search_term_results"
  
  belongs_to :search_term
  belongs_to :study, foreign_key: :nct_id, primary_key: :nct_id
  
  validates :nct_id, presence: true
  validates :search_term_id, presence: true
  validates :nct_id, uniqueness: { scope: :search_term_id }
end