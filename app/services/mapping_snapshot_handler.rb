class MappingSnapshotHandler

  def take_snapshot
    StudyRelationship.load_mappings
    JSON.parse(StudyRelationship.sorted_mapping.to_json)
  rescue StandardError => e
    puts "Error taking snapshot: #{e.message}"
    nil
  end

  
  def latest_snapshot
    latest = Support::CtgovMappingSnapshot.latest_snapshot
  end


  def save(snapshot)
    Support::CtgovMappingSnapshot.create!(snapshot: snapshot)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Error saving snapshot: #{e.message}")
  end

  

  def mapping_changed?(current)
    latest = latest_snapshot
    return true if latest.nil?
    latest != current
  end
end