# Dashboard plot wrappers

#' Plot observed vs forecasts with metrocast theme and labels
#'
#' @param observed Observed tibble
#' @param forecasts Forecast tibble
#' @param facet_by Optional column to facet by
#' @return ggplot object
plot_dashboard_observed_vs_forecast <- function(observed, forecasts, facet_by = NULL) {
  p <- plot_observed_vs_forecast(observed, forecasts, group_col = "model", facet_by = facet_by)
  p + ggplot2::labs(title = "Observed vs Forecasts") + theme_metrocast()
}

#' Plot dashboard quantile ribbons with optional observed overlay
#'
#' @param forecasts Forecast tibble (quantile)
#' @param observed Optional observed tibble
#' @return ggplot object
plot_dashboard_quantiles <- function(forecasts, observed = NULL) {
  p <- plot_quantiles(forecasts, observed_data = observed)
  p + ggplot2::labs(title = "Forecast Quantiles")
}
