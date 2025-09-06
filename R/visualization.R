# Visualization helpers for observed vs forecast comparisons

#' Plot observed values against forecasts
#'
#' Expects a long tibble with columns specifying location, date, value, and metadata.
#' The function draws observed lines and forecast lines, optionally faceting.
#'
#' @param observed_data Tibble with observed values
#' @param forecast_data Tibble with forecasts
#' @param location_col Column name for location identifier
#' @param date_col Column name for target date
#' @param value_col Column name for value
#' @param group_col Optional column to group forecasts (e.g., model)
#' @param facet_by Optional column to facet by (e.g., location)
#' @return ggplot object
plot_observed_vs_forecast <- function(
  observed_data,
  forecast_data,
  location_col = "location",
  date_col = "target_date",
  value_col = "value",
  group_col = "model",
  facet_by = NULL
) {
  # Validate columns
  require_columns(observed_data, c(location_col, date_col, value_col))
  require_columns(forecast_data, c(location_col, date_col, value_col))

  loc <- rlang::sym(location_col)
  date <- rlang::sym(date_col)
  value <- rlang::sym(value_col)
  group <- if (!is.null(group_col)) rlang::sym(group_col) else NULL
  facet <- if (!is.null(facet_by)) rlang::sym(facet_by) else NULL

  p <- ggplot2::ggplot() +
    ggplot2::geom_line(
      data = observed_data,
      ggplot2::aes(x = !!date, y = !!value, group = !!loc),
      color = "black", linewidth = 0.6, alpha = 0.9
    ) +
    ggplot2::geom_line(
      data = forecast_data,
      ggplot2::aes(x = !!date, y = !!value, group = if (!is.null(group)) !!group else !!loc, color = if (!is.null(group)) !!group else NULL),
      linewidth = 0.5, alpha = 0.7
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(x = "Date", y = "Value", color = if (!is.null(group_col)) group_col else NULL)

  if (!is.null(facet)) {
    p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", facet_by)), scales = "free_y")
  }

  p
}
