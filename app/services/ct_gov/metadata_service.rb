module CTGov
  class MetadataService

    def initialize
      @api_version = "2"
      @snapshot_handler = CTGov::MetadataSnapshotHandler.new(@api_version)
    end

    # TODO: report on metadata changes - this means mapping needs to be updated
    def process
      snapshot = @snapshot_handler.take_snapshot

      return if snapshot.nil?

      unless @snapshot_handler.snapshot_changed?(snapshot)
        puts "No changes detected in api metadata"
        return
      end

      ActiveRecord::Base.transaction do
        puts "api metadata changed"
        @snapshot_handler.save_snapshot(snapshot)
        sync_metadata_with_snapshot(snapshot)
      end
    end


    private

    def sync_metadata_with_snapshot(snapshot)
      data = flatten_json(snapshot)
      remove_obsolete_metadata(data)
      create_or_update_metadata(data)
    end

    # process/flatten json
    def flatten_json(node, parent_path = [])
      flattened_data = []

      # metadata returns an array of objects
      if node.is_a?(Array)
        node.each do |child|
          flattened_data += flatten_json(child, parent_path)
        end
      elsif node["children"] # Current node has children, so it's not a leaf node
        current_path = parent_path + [ node["name"] ]
        node["children"].each do |child|
          flattened_data += flatten_json(child, current_path)
        end
      else
        # should be a leaf node
        api_field = {
            name: node["name"],
            data_type: node["type"],
            piece: node["piece"],
            source_type: node["sourceType"],
            synonyms: node["synonyms"],
            label: node.dig("dedLink", "label"),
            url: node.dig("dedLink", "url"),
            path: (parent_path + [ node["name"] ]).join("."),
        } 
        flattened_data << api_field
      end

      flattened_data
    end

    def create_or_update_metadata(data)
      Support::CtgovMetadata.import(
        data,
        validate: true,
        on_duplicate_key_update: {
          conflict_target: [:path],
          columns: [:name, :data_type, :piece, :source_type, :synonyms, :label, :url]
        }
      )
    end


    def remove_obsolete_metadata(data)
      current_paths = data.map { |entry| entry[:path] }
      obsolete_records = Support::CtgovMetadata.where.not(path: current_paths)
      puts "Removing #{obsolete_records.count} obsolete records"
      obsolete_records.delete_all
    end
  end
end