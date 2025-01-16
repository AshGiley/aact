class CreateSearchResultsTables < ActiveRecord::Migration[6.0]
  def change
    create_table "ctgov.search_terms" do |t|
      t.string :term, null: false
      t.string :group, null: true
      t.timestamps null: false
    end

    add_index "ctgov.search_terms", :term, unique: true, 
              name: "index_ctgov_search_terms_on_term"

    create_table "ctgov.search_term_results" do |t|
      t.string :nct_id, null: false
      t.references :search_term, foreign_key: { to_table: "ctgov.search_terms" }, null: false
      t.timestamps null: false
    end

    add_index "ctgov.search_term_results", [:nct_id, :search_term_id], 
              unique: true,
              name: "index_ctgov_search_term_results_on_nct_id_and_search_term_id"
  end
end