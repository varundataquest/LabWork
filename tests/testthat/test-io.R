test_that("dashboard series CSV IO works", {
  series <- tibble::tibble(
    location = c("a", "a"),
    date = as.Date(c("2024-10-01", "2024-10-08")),
    value = c(1.0, 1.2),
    series = c("observed", "forecast"),
    model = c(NA_character_, "m1"),
    quantile = c(NA_real_, NA_real_)
  )
  tmp <- tempfile(fileext = ".csv")
  write_dashboard_series_csv(series, tmp)
  back <- read_dashboard_series_csv(tmp)
  expect_equal(nrow(back), 2)
  expect_true(all(c("location","date","value","series","model","quantile") %in% names(back)))
})
