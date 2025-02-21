module Support
  class Setting < ApplicationRecord
    self.table_name = 'support.settings'

    REGISTRY = {
      export_search_results: false,
      playground_query_limit: 120_000
    }.freeze

    validates :key, presence: true, uniqueness: true
    validates :value, presence: true

    def self.get(key)
      setting = find_by(key: key)
      return setting.value if setting.present?
      
      symbolized_key = key.to_sym
      raise KeyError, "Unknown Setting Key: #{key}" unless REGISTRY.key?(symbolized_key)
      
      REGISTRY[symbolized_key]
    end

    def self.set(key, value)
      record = find_or_initialize_by(key: key)
      record.update!(value: value.to_s) # raise an exception if error
    end


    # helper settings methods
    def self.export_search_results?
      get(:export_search_results).to_s == 'true'
    end

    def self.playground_query_limit
      get(:playground_query_limit).to_i
    end
  end
end