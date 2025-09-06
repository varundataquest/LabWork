# GBM adapter: reshape common GBM notebook outputs to unified schema

#' Adapt GBM outputs (wide-by-quantile) to unified long schema
#'
#' Expects columns like: location, target_date, [q0.05, q0.25, q0.5, q0.75, q0.95], and optionally mean/point.
#'
#' @param df Tibble from GBM model output
#' @param model_name Optional model name to assign
#' @return tibble with columns model, location, target_date, value, quantile
adapt_gbm_quantiles <- function(df, model_name = "gbm") {
  tbl <- as_tibble_safe(df)
  require_columns(tbl, c("location", "target_date"))
  # Detect quantile columns by prefix q or quantile_ style
  q_cols <- grep("^(q|quantile_)[0-9.]+$", names(tbl), value = TRUE)
  if (length(q_cols) == 0) {
    rlang::abort("No quantile columns detected (e.g., q0.05, q0.25, ...)")
  }
  long <- tbl %>%
    tidyr::pivot_longer(cols = dplyr::all_of(q_cols), names_to = "quantile_label", values_to = "value") %>%
    dplyr::mutate(quantile = suppressWarnings(as.numeric(stringr::str_replace(quantile_label, "^(q|quantile_)", "")))) %>%
    dplyr::transmute(model = model_name, location = .data[["location"]], target_date = .data[["target_date"]], value = .data[["value"]], quantile = .data[["quantile"]])
  long
}
