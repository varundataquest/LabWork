# Metrocast adapters and helpers

#' Remap columns based on a candidate mapping
#'
#' Given a list of target_name -> character vector of candidate source names,
#' finds the first existing source per target and renames it to target_name.
#'
#' @param df data.frame/tibble
#' @param candidates named list: names are target columns; values are character vectors of candidate existing names
#' @return tibble with columns renamed where possible
remap_columns_first_match <- function(df, candidates) {
  tbl <- as_tibble_safe(df)
  for (target_name in names(candidates)) {
    options <- candidates[[target_name]]
    if (!is.character(options)) next
    present <- intersect(options, names(tbl))
    if (length(present) >= 1 && !(target_name %in% names(tbl))) {
      tbl <- dplyr::rename(tbl, !!rlang::sym(target_name) := dplyr::all_of(present[[1]]))
    }
  }
  tbl
}

#' Convert a forecast dataframe to a metrocast-compatible schema
#'
#' Tries to unify columns to the canonical set used by hubtools and metrocast workflows:
#' `model`, `issuance_date`, `target_date`, `location`, `type`, `quantile`, `horizon`, `value`.
#'
#' @param df Forecast tibble
#' @param file_path Optional file path (to infer model if missing)
#' @return tibble with unified columns and coerced types
#' @examples
#' # unified <- to_metrocast_schema(df)
#' to_metrocast_schema <- function(df, file_path = NULL) {
  tbl <- as_tibble_safe(df)
  tbl <- remap_columns_first_match(tbl, list(
    location = c("location", "geo_value", "county", "hsa", "state"),
    target_date = c("target_date", "target_end_date", "date"),
    issuance_date = c("issuance_date", "forecast_date", "reference_date", "issue_date"),
    value = c("value", "mean", "point"),
    quantile = c("quantile", "q"),
    model = c("model", "model_id", "model_name"),
    horizon = c("horizon"),
    type = c("type", "output_type")
  ))

  # Fill model from path if missing
  if (!("model" %in% names(tbl))) {
    derived <- if (!is.null(file_path)) .guess_model_from_path(file_path) else NA_character_
    tbl$model <- derived
  }

  # Type coercions
  if ("issuance_date" %in% names(tbl)) tbl$issuance_date <- suppressWarnings(lubridate::as_date(tbl$issuance_date))
  if ("target_date" %in% names(tbl)) tbl$target_date <- suppressWarnings(lubridate::as_date(tbl$target_date))
  if ("quantile" %in% names(tbl)) tbl$quantile <- suppressWarnings(as.numeric(tbl$quantile))
  if ("horizon" %in% names(tbl)) tbl$horizon <- suppressWarnings(as.integer(tbl$horizon))

  tbl
}

#' Read metrocast-style forecasts from a directory and unify schema
#'
#' @param directory Directory containing CSVs (nested by model allowed)
#' @param recursive Whether to recurse into subdirectories
#' @return tibble of combined unified forecasts
read_metrocast_forecast_dir <- function(directory, recursive = TRUE) {
  stopifnot(dir.exists(directory))
  csv_files <- list.files(directory, pattern = "\\.csv$", recursive = recursive, full.names = TRUE)
  if (length(csv_files) == 0) return(tibble::tibble())
  purrr::map_dfr(csv_files, function(p) {
    df <- readr::read_csv(p, show_col_types = FALSE, progress = FALSE)
    to_metrocast_schema(df, file_path = p)
  })
}

#' Build dashboard-ready tidy series from observed and forecast data
#'
#' Returns a tidy table with columns: location, date, value, series, model, quantile (optional).
#'
#' @param observed Observed tibble with columns location, target_date/date, value
#' @param forecasts Forecast tibble in unified schema (model, target_date, location, value, quantile optional)
#' @param observed_date_col Name of observed date column (default "target_date")
#' @return tibble suitable for dashboard consumption
build_dashboard_series <- function(observed, forecasts, observed_date_col = "target_date") {
  obs_tbl <- as_tibble_safe(observed)
  f_tbl <- as_tibble_safe(forecasts)
  # Normalize observed date col
  if (!(observed_date_col %in% names(obs_tbl)) && "date" %in% names(obs_tbl)) observed_date_col <- "date"
  require_columns(obs_tbl, c("location", observed_date_col, "value"))
  require_columns(f_tbl, c("location", "target_date", "value"))

  obs_out <- obs_tbl %>%
    dplyr::transmute(location = .data[["location"]], date = .data[[observed_date_col]], value = .data[["value"]], series = "observed", model = NA_character_, quantile = NA_real_)

  # Separate quantile vs point forecasts
  has_quantiles <- ("quantile" %in% names(f_tbl)) && any(!is.na(f_tbl$quantile))
  if (has_quantiles) {
    f_q <- f_tbl %>% dplyr::filter(!is.na(.data[["quantile"]])) %>%
      dplyr::transmute(location = .data[["location"]], date = .data[["target_date"]], value = .data[["value"]], series = "quantile", model = .data[["model"]], quantile = .data[["quantile"]])
  } else {
    f_q <- tibble::tibble(location = character(), date = as.Date(character()), value = numeric(), series = character(), model = character(), quantile = numeric())
  }

  f_pt <- f_tbl %>% dplyr::filter(is.na(.data[["quantile"]]) | !("quantile" %in% names(f_tbl))) %>%
    dplyr::transmute(location = .data[["location"]], date = .data[["target_date"]], value = .data[["value"]], series = "forecast", model = .data[["model"]], quantile = NA_real_)

  dplyr::bind_rows(obs_out, f_pt, f_q)
}
