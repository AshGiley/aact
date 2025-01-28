module CTGov
  class MetadataSnapshotHandler

    def initialize(api_version)
      @api_version = api_version
    end

    def take_snapshot
      take_snapshot_from_file
    rescue StandardError => e
      Rails.logger.error("Failed to retrieve snapshot for api version: #{@api_version}")
      nil # TODO: raise error based on future logic on calling side
    end


    # TODO: review using DI for a model
    def latest_snapshot
      Support::CtgovMetadataSnapshot.latest_snapshot_for(@api_version)
    end


    def save(snapshot)
      Support::CtgovMetadataSnapshot.create!(api_version: @api_version, snapshot: snapshot)
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Error saving snapshot: #{e.message}")
    end


    def metadata_changed?(current)
      latest = latest_snapshot
      return true if latest.nil?
      latest != current
    end

    private

    def take_snapshot_from_api
      # TODO: implement fetching from api metadata endpoint
    end


    # TODO: create util to read from json file (mesh headings and terms)
    def take_snapshot_from_file
      file_path = Rails.root.join("lib", "ctgov", "metadata.json")
      file_content = File.read(file_path)
      JSON.parse(file_content)
    rescue Errno::ENOENT => e
      Rails.logger.error("File not found: #{file_path}")
      raise e
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse JSON from file: #{e.message}")
      raise e
    end
  end
end