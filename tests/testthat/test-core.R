test_that("evaluate_mae works", {
  df <- tibble::tibble(observed = c(1,2,3), predicted = c(1,3,2), model = "m1")
  expect_equal(round(evaluate_mae(df), 3), 0.667)
})

test_that("read_forecast_dir handles empty", {
  tmp <- tempdir()
  dir.create(file.path(tmp, "emptydir"))
  res <- read_forecast_dir(file.path(tmp, "emptydir"))
  expect_true(is.data.frame(res))
  expect_equal(nrow(res), 0)
})
