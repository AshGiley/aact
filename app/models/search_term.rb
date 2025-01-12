class SearchTerm < ApplicationRecord
  self.table_name = "ctgov.search_terms"
  
  has_many :search_term_results
  validates :term, presence: true, uniqueness: true
end