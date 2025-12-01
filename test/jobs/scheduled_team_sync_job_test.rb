require "test_helper"

class ScheduledTeamSyncJobTest < ActiveJob::TestCase
  test "syncs during November" do
    travel_to Date.new(2024, 11, 15) do
      TeamSource.create!(short_name: "T1", long_name: "T1", external_team_url: "http://example.com")

      assert_enqueued_with(job: TeamSyncJob) do
        ScheduledTeamSyncJob.perform_now
      end
    end
  end

  test "syncs during December" do
    travel_to Date.new(2024, 12, 20) do
      TeamSource.create!(short_name: "T1", long_name: "T1", external_team_url: "http://example.com")

      assert_enqueued_with(job: TeamSyncJob) do
        ScheduledTeamSyncJob.perform_now
      end
    end
  end

  test "syncs during January" do
    travel_to Date.new(2024, 1, 25) do
      TeamSource.create!(short_name: "T1", long_name: "T1", external_team_url: "http://example.com")

      assert_enqueued_with(job: TeamSyncJob) do
        ScheduledTeamSyncJob.perform_now
      end
    end
  end

  test "syncs during first week of regular season month" do
    travel_to Date.new(2024, 3, 5) do
      TeamSource.create!(short_name: "T1", long_name: "T1", external_team_url: "http://example.com")

      assert_enqueued_with(job: TeamSyncJob) do
        ScheduledTeamSyncJob.perform_now
      end
    end
  end

  test "does not sync after first week of regular season month" do
    travel_to Date.new(2024, 3, 15) do
      TeamSource.create!(short_name: "T1", long_name: "T1", external_team_url: "http://example.com")

      assert_no_enqueued_jobs do
        ScheduledTeamSyncJob.perform_now
      end
    end
  end

  test "syncs on day 7 of regular season month" do
    travel_to Date.new(2024, 2, 7) do
      TeamSource.create!(short_name: "T1", long_name: "T1", external_team_url: "http://example.com")

      assert_enqueued_with(job: TeamSyncJob) do
        ScheduledTeamSyncJob.perform_now
      end
    end
  end

  test "does not sync on day 8 of regular season month" do
    travel_to Date.new(2024, 2, 8) do
      TeamSource.create!(short_name: "T1", long_name: "T1", external_team_url: "http://example.com")

      assert_no_enqueued_jobs do
        ScheduledTeamSyncJob.perform_now
      end
    end
  end

  test "enqueues job for each team source" do
    travel_to Date.new(2024, 11, 15) do
      3.times { |i| TeamSource.create!(short_name: "T#{i}", long_name: "Team #{i}", external_team_url: "http://example.com/#{i}") }

      assert_enqueued_jobs 3, only: TeamSyncJob do
        ScheduledTeamSyncJob.perform_now
      end
    end
  end
end
