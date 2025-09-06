test_that("evaluate_wis returns numeric and non-negative", {
  fc <- tibble::tibble(
    model = "m1",
    location = "a",
    target_date = as.Date("2024-10-01"),
    quantile = c(0.05, 0.25, 0.5, 0.75, 0.95),
    value = c(1, 2, 3, 4, 5)
  )
  truth <- tibble::tibble(model = "m1", location = "a", target_date = as.Date("2024-10-01"), observed = 3.2)
  out <- evaluate_wis(fc, truth)
  expect_true(is.numeric(out$wis))
  expect_true(out$wis >= 0)
})

test_that("evaluate_crps_from_quantiles equals WIS for same input", {
  fc <- tibble::tibble(
    model = "m1",
    location = "a",
    target_date = as.Date("2024-10-01"),
    quantile = c(0.05, 0.25, 0.5, 0.75, 0.95),
    value = c(1, 2, 3, 4, 5)
  )
  truth <- tibble::tibble(model = "m1", location = "a", target_date = as.Date("2024-10-01"), observed = 3.2)
  wis <- evaluate_wis(fc, truth)
  crps <- evaluate_crps_from_quantiles(fc, truth)
  expect_equal(wis$wis, crps$crps)
})
