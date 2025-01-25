module Support
  class Setting < ApplicationRecord
    self.table_name = 'support.settings'

    validates :key, presence: true, uniqueness: true
    validates :value, presence: true

    def self.get(key)
      setting = find_by(key: key)
      setting&.value
    end

    def self.set(key, value)
      record = find_or_initialize_by(key: key)
      record.update!(value: value.to_s) # raise an exception if error
    end


    # helper settings methods
    def self.export_search_results?
      get('export_search_results').to_s == 'true'
    end
    
  end
end