test_that("standardize_forecast_df maps common columns", {
  df <- tibble::tibble(
    target_end_date = as.Date(c("2024-10-01", "2024-10-08")),
    forecast_date = as.Date(c("2024-09-24", "2024-10-01")),
    target = c("1 wk ahead", "2 wk ahead"),
    location = c("city_a", "city_a"),
    mean = c(1.2, 1.5)
  )
  std <- standardize_forecast_df(df)
  expect_true(all(c("target_date", "issuance_date", "horizon", "value") %in% names(std)))
  expect_true("model" %in% names(std))
  expect_equal(std$horizon, c(1L, 2L))
})

test_that("read_hub_forecast_dir handles empty directories", {
  tmp <- tempfile("dir")
  dir.create(tmp)
  res <- read_hub_forecast_dir(tmp)
  expect_true(is.data.frame(res))
  expect_equal(nrow(res), 0)
})
