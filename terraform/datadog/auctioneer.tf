resource "datadog_monitor" "auctioneer_lock_held_once" {
  name                = "${format("%s auctioneer lock held exactly once (%s)", var.env, element(list("upper", "lower"), count.index))}"
  type                = "query alert"
  message             = "There is not exactly one auctioneer holding the lock."
  escalation_message  = "There is still not exactly one auctioneer holding the lock."
  notify_no_data      = false
  require_full_window = true

  count = 2

  query = "${
    format(
      "%s(last_5m):sum:cf.auctioneer.LockHeld.v1_locks_auctioneer_lock{deployment:%s}.fill(last, 60) %s",
      element(list("max", "min"), count.index),
      var.env,
      element(list("> 1", "< 1"), count.index)
    )}"

  thresholds {
    critical = "1" # This value must match the threshold set in the query. Otherwise datadog API would fail obscurely
  }

  tags = ["deployment:${var.env}", "service:${var.env}_monitors", "job:auctioneer"]
}
