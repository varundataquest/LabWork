# Data ingestion and filtering utilities compatible with hub-style forecasts

#' Read forecast CSV files from a directory into a single tibble
#'
#' This helper reads all CSV files in a directory (non-recursive by default)
#' and binds them into a single tibble with a `file_path` column.
#' It assumes a wide variety of forecast schemas; downstream functions should
#' standardize column names as needed.
#'
#' @param directory Path to directory containing CSV files
#' @param recursive Whether to search subdirectories
#' @return Tibble of concatenated data with a `file_path` column
#' @examples
#' # forecasts <- read_forecast_dir("path/to/forecasts")
read_forecast_dir <- function(directory, recursive = FALSE) {
  stopifnot(dir.exists(directory))
  csv_files <- list.files(directory, pattern = "\\.csv$", recursive = recursive, full.names = TRUE)
  if (length(csv_files) == 0) {
    return(tibble::tibble())
  }
  purrr::map_dfr(csv_files, function(path) {
    df <- readr::read_csv(path, show_col_types = FALSE, progress = FALSE)
    df$file_path <- path
    tibble::as_tibble(df)
  })
}

#' Filter forecasts by fixing an issuance date (all horizons from that issue)
#'
#' @param forecasts Tibble with at least columns: `issuance_date` and `horizon`
#' @param issuance_date Date or character parsable by lubridate
#' @param issuance_col Name of issuance date column (default `issuance_date`)
#' @return Filtered tibble
filter_by_fix_date <- function(forecasts, issuance_date, issuance_col = "issuance_date") {
  if (!inherits(issuance_date, "Date")) issuance_date <- lubridate::as_date(issuance_date)
  issuance_sym <- rlang::sym(issuance_col)
  dplyr::filter(forecasts, !!issuance_sym == issuance_date)
}

#' Filter forecasts by fixing a horizon across multiple issuance dates
#'
#' @param forecasts Tibble with at least `horizon` and `issuance_date`
#' @param horizon Integer horizon value to filter
#' @param horizon_col Name of horizon column (default `horizon`)
#' @return Filtered tibble
filter_by_fix_horizon <- function(forecasts, horizon, horizon_col = "horizon") {
  horizon_sym <- rlang::sym(horizon_col)
  dplyr::filter(forecasts, !!horizon_sym == horizon)
}
