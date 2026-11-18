require "test_helper"

class CloseStalePendingTicketsJobTest < ActiveJob::TestCase
  test "closes tickets pending longer than the limit" do
    tickets(:invoice).update_column(:pending_since, 8.days.ago)

    CloseStalePendingTicketsJob.perform_now(days: 7)

    assert tickets(:invoice).reload.closed?
  end

  test "leaves recently pending and open tickets alone" do
    tickets(:login).update_column(:updated_at, 30.days.ago)

    CloseStalePendingTicketsJob.perform_now(days: 7)

    assert tickets(:invoice).reload.pending?
    assert tickets(:login).reload.open?
  end

  test "a limit of 0 turns auto-close off" do
    tickets(:invoice).update_column(:pending_since, 100.days.ago)
    CloseStalePendingTicketsJob.perform_now(days: 0)
    assert tickets(:invoice).reload.pending?
  end
end
