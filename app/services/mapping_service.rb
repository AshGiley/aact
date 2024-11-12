class MappingService

  def process
    snapshot = take_snapshot

    ActiveRecord::Base.transaction do
      if mapping_changed?(snapshot)
        puts "Changes detected in mapping, creating snapshot"
        Support::CtgovMappingSnapshot.create(snapshot: snapshot)

        # process json snapshot
        mappings = process_json(snapshot)
        # byebug
        deduplicated_mappings = mappings.uniq { |entry| [ entry[:table_name], entry[:field_name], entry[:api_path] ] }
        # Bulk upsert operation for efficiency
        Support::CtgovMapping.upsert_all(deduplicated_mappings, unique_by: [ :table_name, :field_name, :api_path ])

        # Remove records in CtgovApi::Mapping that are not in the current snapshot
        remove_obsolete_mappings(deduplicated_mappings)
      else
        puts "No changes detected in mapping"
      end
    end
  end


  private

  def take_snapshot
    StudyRelationship.load_mappings
    JSON.parse(StudyRelationship.sorted_mapping.to_json)
  end


  def mapping_changed?(current)
    latest = Support::CtgovMappingSnapshot.latest_snapshot
    return true if latest.nil?
    latest != current
  end

  def process_json(mappings, parent_root = nil)
    all_mappings = [] # aka records in the mapping table

    mappings.each do |mapping|
      root = build_root(parent_root, mapping)
      # all_mappings += extract_mapping_entries(map, root) # switch to concat for memory efficiency

      # check for mapping without columns
      mapping["columns"].each do |column|
        full_path_array = build_full_path(root, column["value"])
        api_path = full_path_array.join(".")

        all_mappings << {
          table_name: mapping["table"],
          field_name: column["name"],
          api_path: api_path,
          created_at: Time.now,
          updated_at: Time.now
        }
      end

      if mapping["children"]
        all_mappings += process_json(mapping["children"], root)
      end
    end
    all_mappings
  end


  def build_root(parent_root, mapping)
    root = parent_root ? parent_root.dup : []
    root += mapping["root"] if mapping["root"]
    # TODO: double check auto adding of flatten
    root += mapping["flatten"] if mapping["flatten"]
    root
  end

  def build_full_path(root, value)
    full_path = root ? root.dup : []

    if value.is_a?(Array)
      # Handle $parent references
      value.each do |v|
        if v == "$parent"
          full_path.pop # Remove the last element (going "up" one level)
        else
          full_path << v
        end
      end
    else
      full_path << value
    end

    full_path
  end


  def remove_obsolete_mappings(mappings)
    # key from active mapping snapshot
    snapshot_keys = mappings.map { |entry| [entry[:table_name], entry[:field_name], entry[:api_path]] }

    # get 1000 records batch by default
    Support::CtgovMapping.find_each do |db_mapping|
      db_key = [db_mapping.table_name, db_mapping.field_name, db_mapping.api_path]
      
      unless snapshot_keys.include?(db_key)
        db_mapping.delete
        puts "Removed mapping: #{db_key}"
      end
    end
  end
end
