module CTGov
  module Metadata
    class Service

      def process
        snapshot = take_snapshot
        

        if metadata_changed?(snapshot)
          data = flatten_json(snapshot)

          remove_obsolete_metadata(data)

          Support::CtgovMetadata.import(
            data,
            validate: true,
            on_duplicate_key_update: {
              conflict_target: [:path],
              columns: [:name, :data_type, :piece, :source_type, :synonyms, :label, :url]
            }
          )
        else
          puts "No changes in metadata"
        end
      end


      private 

      # faking the snapshot
      def take_snapshot
        file_path = Rails.root.join("lib", "ctgov", "metadata.json")
        file_content = File.read(file_path)
        JSON.parse(file_content)
      end

      # faking changed condition
      def metadata_changed?(current)
        true
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


      def remove_obsolete_metadata(data)
        puts "Removing obsolete metadata"
        current_paths = data.map { |entry| entry[:path] }
        
        obsolete_records = Support::CtgovMetadata.where.not(path: current_paths)
        puts "Removing #{obsolete_records.count} obsolete records"
        obsolete_records.delete_all
      end
    end
  end
end