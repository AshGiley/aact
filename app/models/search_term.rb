class SearchTerm < ActiveRecord::Base
  self.table_name = "ctgov.search_terms"
  
  before_save :normalize_term
  has_many :search_term_results
  validates :term, presence: true, uniqueness: true
  attribute :group, :string, default: 'other'

  private

  def normalize_term
    self.term = term.downcase
    self.group = group.downcase
  end
end