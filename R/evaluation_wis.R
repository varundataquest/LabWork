# Weighted Interval Score (WIS) and CRPS from quantiles

#' Compute Weighted Interval Score (WIS) for quantile forecasts
#'
#' Expects a long tibble of forecasts with quantile predictions and a truth table.
#' The function computes WIS per group (e.g., model/location/target_date) using
#' standard Forecast Hub weighting: w0 = 0.5 for the median, and wk = alpha/2 for
#' each central prediction interval defined by quantile pairs (alpha/2, 1 - alpha/2).
#'
#' @param forecasts Long tibble with columns: quantile (0-1), value, and grouping columns
#' @param truth Tibble with observed values; must contain columns in `by` and `truth_col`
#' @param by Character vector of grouping columns shared by forecasts and truth
#' @param truth_col Name of observed value column in `truth` (default "observed")
#' @return tibble with one row per group and columns: wis, n_intervals, used_median
#' @examples
#' # scores <- evaluate_wis(fc_long, truth_df, by=c("model","location","target_date"))
evaluate_wis <- function(forecasts, truth, by = c("model", "location", "target_date"), truth_col = "observed") {
  require_columns(forecasts, c(by, "quantile", "value"))
  require_columns(truth, c(by, truth_col))

  forecasts %>%
    dplyr::inner_join(truth, by = by) %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) %>%
    dplyr::group_modify(~ tibble::tibble(wis = .compute_wis_one_group(.x, truth_col = truth_col))) %>%
    dplyr::ungroup()
}

#' Compute CRPS from quantile forecasts (WIS-equivalent)
#'
#' For quantile forecasts, the WIS is a proper scoring rule that coincides with
#' the CRPS of a consistent piecewise-uniform distribution. This function returns
#' the same value as WIS for the provided quantiles.
#'
#' @inheritParams evaluate_wis
#' @return tibble with one row per group and column: crps
#' @examples
#' # scores <- evaluate_crps_from_quantiles(fc_long, truth_df)
evaluate_crps_from_quantiles <- function(forecasts, truth, by = c("model", "location", "target_date"), truth_col = "observed") {
  evaluate_wis(forecasts, truth, by = by, truth_col = truth_col) %>%
    dplyr::rename(crps = wis)
}

# Internal: compute WIS for a single grouped tibble
# Returns a numeric scalar
.compute_wis_one_group <- function(df_group, truth_col) {
  y <- df_group[[truth_col]][[1]]

  # Extract median if present
  has_median <- any(df_group$quantile == 0.5, na.rm = TRUE)
  median_val <- NA_real_
  if (has_median) {
    median_val <- df_group$value[df_group$quantile == 0.5][[1]]
  }

  # Build available central intervals from quantile pairs
  qs <- sort(unique(df_group$quantile[!is.na(df_group$quantile)]))
  qs <- qs[qs > 0 & qs < 1]
  # Candidate alphas from available quantiles (excluding median)
  alphas_all <- unique(round(2 * abs(qs - 0.5), digits = 6))
  alphas_all <- alphas_all[alphas_all > 0 & alphas_all < 1]

  # Keep only alphas with both lower (a/2) and upper (1-a/2) present
  has_pair <- function(a) {
    l <- round(a / 2, 6); u <- round(1 - a / 2, 6)
    any(abs(qs - l) < 1e-6) && any(abs(qs - u) < 1e-6)
  }
  alphas <- alphas_all[purrr::map_lgl(alphas_all, has_pair)]
  if (length(alphas) == 0 && !has_median) return(NA_real_)

  # Weights and components
  w0 <- 0.5
  K <- length(alphas)
  denom <- K + if (has_median) 0.5 else 0

  # Median absolute error term
  term_median <- if (has_median) w0 * abs(y - median_val) else 0

  # Interval score terms
  interval_sum <- 0
  for (a in alphas) {
    l <- a / 2; u <- 1 - a / 2
    l_val <- df_group$value[which.min(abs(df_group$quantile - l))]
    u_val <- df_group$value[which.min(abs(df_group$quantile - u))]
    iscore <- (u_val - l_val) + (2 / a) * max(l_val - y, 0) + (2 / a) * max(y - u_val, 0)
    interval_sum <- interval_sum + (a / 2) * iscore
  }

  wis <- (term_median + interval_sum) / denom
  wis
}
