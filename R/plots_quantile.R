# Quantile plotting helpers and theme

#' Plot forecast quantile ribbons with optional observed overlay
#'
#' Expects forecast_data with columns: location, target_date, quantile, value,
#' and optional model. Uses two bands (5-95, 25-75) and a median line (0.5).
#'
#' @param forecast_data Tibble of quantile forecasts
#' @param observed_data Optional tibble of observed values with columns location, target_date, value
#' @param location_col Column for location
#' @param date_col Column for date (target date)
#' @param value_col Column for value
#' @param model_col Optional model column to facet by if present
#' @return ggplot object
plot_quantiles <- function(
  forecast_data,
  observed_data = NULL,
  location_col = "location",
  date_col = "target_date",
  value_col = "value",
  model_col = "model"
) {
  require_columns(forecast_data, c(location_col, date_col, "quantile", value_col))

  value_sym <- rlang::sym(value_col)

  base_cols <- unique(c(location_col, date_col, model_col))
  base_cols <- base_cols[base_cols %in% names(forecast_data)]

  fc <- forecast_data %>%
    dplyr::filter(.data[["quantile"]] %in% c(0.05, 0.25, 0.5, 0.75, 0.95)) %>%
    dplyr::mutate(q_label = dplyr::case_when(
      .data[["quantile"]] == 0.05 ~ "q05",
      .data[["quantile"]] == 0.25 ~ "q25",
      .data[["quantile"]] == 0.5 ~ "q50",
      .data[["quantile"]] == 0.75 ~ "q75",
      .data[["quantile"]] == 0.95 ~ "q95",
      TRUE ~ NA_character_
    )) %>%
    dplyr::select(dplyr::any_of(base_cols), q_label, value = !!value_sym) %>%
    tidyr::pivot_wider(names_from = q_label, values_from = value)

  p <- ggplot2::ggplot(fc, ggplot2::aes(x = .data[[date_col]])) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = .data[["q05"]], ymax = .data[["q95"]]), fill = "#9ecae1", alpha = 0.35) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = .data[["q25"]], ymax = .data[["q75"]]), fill = "#4292c6", alpha = 0.35) +
    ggplot2::geom_line(ggplot2::aes(y = .data[["q50"]]), color = "#08519c", linewidth = 0.6)

  if (!is.null(observed_data)) {
    require_columns(observed_data, c(location_col, date_col, value_col))
    p <- p + ggplot2::geom_line(data = observed_data, ggplot2::aes(x = .data[[date_col]], y = .data[[value_col]]), color = "black", linewidth = 0.6)
  }

  if (!is.null(model_col) && model_col %in% names(forecast_data)) {
    p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", model_col)))
  }

  p + theme_metrocast() + ggplot2::labs(x = "Date", y = "Value")
}

#' Metrocast ggplot theme
#'
#' A clean minimal theme with improved grid and text for dashboards.
#'
#' @return a ggplot2 theme
#' @examples
#' # p + theme_metrocast()
theme_metrocast <- function() {
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_line(color = "#f0f0f0"),
      panel.grid.major.y = ggplot2::element_line(color = "#e0e0e0"),
      strip.background = ggplot2::element_rect(fill = "#f7f7f7", color = NA),
      strip.text = ggplot2::element_text(face = "bold"),
      plot.title = ggplot2::element_text(face = "bold")
    )
}
