module Util
  class UpdaterV2
    include SchemaSwitcher

    attr_reader :params, :schema

    def initialize(params = {})
      @params = params
      @type = (params[:event_type] || "incremental")
      @schema = params[:schema] || "ctgov"
      @sync_service = CTGov::StudySyncService.new
      @search_service = CTGov::SearchResultsService.new
    end


    def run_main_loop
      loop do
        now = TZInfo::Timezone.get("America/New_York").now
        if Support::LoadEvent.where("created_at > ?", now.beginning_of_day).count == 0
          execute
        else
          ActiveRecord::Base.logger = nil
          update_current_studies
        end
      end
    end
    

    def execute
      ActiveRecord::Base.logger = nil
      @step_count = 0
      create_load_event
      log("🚀🚀🚀 Execute Event for #{@schema} schema 🚀🚀🚀", false, true)
      run_step("Download Studies") { @sync_service.sync_recent_studies_from_api }
      run_step("Remove Indexes/Contraints") { db_mgr.remove_indexes_and_constraints }
      run_step("Process Studies") { worker.import_all}
      run_step("Add Indexes/Constraints") { db_mgr.add_indexes_and_constraints }
      run_step("Compare Counts", skipped = true)
      run_step("Study Searches", skipped = true)
      run_step("Process Search Terms") { process_search_terms }
      run_step("Sanity Checks") { @load_event.run_sanity_checks(@schema) }

      if @load_event.sanity_checks.count == 0
        run_step("Take DB Snapshot") { take_snapshot }
        run_step("Refresh Public DB") { db_mgr.refresh_public_db }
        run_step("Create Flat Files") { create_flat_files }
        log("🏁🏁🏁 Execute Event Completed 🏁🏁🏁", false)
        @load_event.update({ status: "complete", completed_at: Time.now})
      else
        log("🛑 Execution Stopped: Discrepancies Found During Sanity Checks")
        @load_event.update({ status: "stopped", completed_at: Time.now})
      end

    rescue => e
      @load_event.update({ status: "error"}) 
      @load_event.update({ problems: "#{e.message}\n\n#{e.backtrace.join("\n")}" })
      log("⛔ Execute Stopped at Step #{@step_count} because of #{e.message}", log_event = false)
      Airbrake.notify(e)
    end

    private
    
    def worker
      @worker ||= StudyJsonRecord::Worker.new
    end

    def db_mgr
      # makes it "singleton-like" inside the class
      @db_mgr ||= Util::DbManager.new(event: @load_event, schema: @schema)
    end

    def update_current_studies
      @sync_service.refresh_studies_from_db
      db_mgr.remove_indexes_and_constraints
      worker.import_all
      # db_mgr.add_indexes_and_constraints # test how much this slows down the process
    rescue => e
      puts "⛔ Error in updating current studies: #{e.message}"
      Airbrake.notify(e)
    end

    def take_snapshot
      log("dumping database...", false)
      filename = db_mgr.dump_database

      log("zipping and updloading db dump to cloud...", false)
      Util::FileManager.new.save_static_copy(filename, @schema)
      rescue StandardError => e
        @load_event.add_problem("#{e.message} (#{e.class} #{e.backtrace}")
    end

    def process_search_terms
      return unless Support::Setting.export_search_results?

      groups = SearchTerm.distinct.pluck(:group).compact
      log("Processing #{groups.count} search term groups...")

      groups.each do |group|
        begin
          log("Refreshing search results for group: #{group}")
          @search_service.refresh_search_results_for(group)
        rescue => e
          log("Error processing group #{group}: #{e.message}")
          @load_event.add_problem("Failed to process search group #{group}: #{e.message}")
          # Continue with other groups rather than failing completely
          next
        end
      end
    end

    def create_flat_files
      log("working hard on creating flat files...", false)
      Util::TableExporter.new([], @schema).run(delimiter: '|')
    end

    def create_load_event
      @load_event = Support::LoadEvent.create({
        event_type: @type,
        status: "running",
        description: "🛠️  Execute Load Event for #{@schema} schema\n",
        problems: "" 
      })
    end


    def run_step(description, skipped = false)
      @step_count += 1
      start_time = Time.zone.now
      if skipped
        log("Step #{@step_count}: ⏭️  #{description}")
        puts "------------------------------------------------------------------"
      else
        puts "[#{timestamp}] - Step #{@step_count}: ⏳ #{description}"
        yield if block_given?
        end_time = Time.zone.now
        duration = end_time - start_time
        log("Step #{@step_count}: ✅ #{description} (#{duration.round(2)} sec)")
        puts "------------------------------------------------------------------"
      end
    end


    def log(msg, event_log = true, day_only = false)
      formatted_message = "[#{timestamp(day_only)}] - #{msg}\n"
      @load_event.log(msg) if event_log
      puts formatted_message
    end

    def timestamp(day_only = false)
      if day_only
        Time.zone.now.strftime("%Y-%m-%d")
      else
        Time.zone.now.strftime("%I:%M:%S %p")
      end
    end
  end
end
