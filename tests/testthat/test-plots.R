test_that("plot_quantiles returns a ggplot", {
  fc <- tibble::tibble(
    location = rep("city_a", 5),
    target_date = as.Date(rep("2024-10-01", 5)),
    quantile = c(0.05, 0.25, 0.5, 0.75, 0.95),
    value = c(1, 2, 3, 4, 5),
    model = "m1"
  )
  p <- plot_quantiles(fc)
  expect_true(inherits(p, "ggplot"))
})
