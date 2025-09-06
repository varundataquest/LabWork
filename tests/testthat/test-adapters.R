test_that("remap_columns_first_match renames correctly", {
  df <- tibble::tibble(geo_value = c("a"), date = as.Date("2024-10-01"), mean = 1.0)
  out <- remap_columns_first_match(df, list(location = c("location", "geo_value"), target_date = c("target_date", "date"), value = c("value", "mean")))
  expect_true(all(c("location", "target_date", "value") %in% names(out)))
})

test_that("to_metrocast_schema coerces and fills model", {
  df <- tibble::tibble(geo_value = c("a"), target_end_date = as.Date("2024-10-01"), forecast_date = as.Date("2024-09-24"), mean = 1.2)
  out <- to_metrocast_schema(df)
  expect_true(all(c("location", "target_date", "issuance_date", "value", "model") %in% names(out)))
})

test_that("adapt_gbm_quantiles reshapes q-columns", {
  df <- tibble::tibble(location = "a", target_date = as.Date("2024-10-01"), q0.05 = 1, q0.5 = 2, q0.95 = 3)
  out <- adapt_gbm_quantiles(df, model_name = "gbm_test")
  expect_true(all(c("model", "location", "target_date", "value", "quantile") %in% names(out)))
  expect_equal(sort(unique(out$quantile)), c(0.05, 0.5, 0.95))
})
