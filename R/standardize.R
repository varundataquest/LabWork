# Standardization helpers for Forecast Hub CSVs

# Infer model name from file path by using parent directory name
# @noRd
.guess_model_from_path <- function(path) {
  base::basename(base::dirname(path))
}

# Parse integer horizon from a target string like "1 wk ahead"
# @noRd
.parse_horizon_from_target <- function(target_vector) {
  suppressWarnings(as.integer(stringr::str_extract(target_vector, "\\d+")))
}

#' Standardize forecast dataframe to canonical columns
#'
#' Attempts to map common Forecast Hub column names to a standard set:
#' `model`, `issuance_date`, `target_date`, `location`, `type`, `quantile`, `horizon`, `value`.
#' Missing optional columns will be created if they can be inferred.
#'
#' @param df A forecast data.frame/tibble
#' @param file_path Optional original file path to derive model if needed
#' @return tibble with standardized columns where possible
standardize_forecast_df <- function(df, file_path = NULL) {
  tbl <- as_tibble_safe(df)

  # Rename common variants to canonical names (map old -> new)
  rename_map <- c(
    target_end_date = "target_date",
    forecast_date = "issuance_date",
    reference_date = "issuance_date",
    mean = "value"
  )
  for (old_name in names(rename_map)) {
    new_name <- rename_map[[old_name]]
    if (old_name %in% names(tbl) && !(new_name %in% names(tbl))) {
      tbl <- dplyr::rename(tbl, !!rlang::sym(new_name) := .data[[old_name]])
    }
  }

  # Ensure model column
  if (!("model" %in% names(tbl))) {
    derived <- if (!is.null(file_path)) .guess_model_from_path(file_path) else NA_character_
    tbl$model <- derived
  }

  # Ensure horizon column
  if (!("horizon" %in% names(tbl))) {
    if ("target" %in% names(tbl)) {
      tbl$horizon <- .parse_horizon_from_target(tbl$target)
    } else {
      tbl$horizon <- NA_integer_
    }
  }

  # Coerce dates when possible
  if ("issuance_date" %in% names(tbl)) {
    tbl$issuance_date <- suppressWarnings(lubridate::as_date(tbl$issuance_date))
  }
  if ("target_date" %in% names(tbl)) {
    tbl$target_date <- suppressWarnings(lubridate::as_date(tbl$target_date))
  }

  tbl
}

#' Read and standardize all Forecast Hub CSVs in a directory
#'
#' @param directory Directory containing CSVs
#' @param recursive Recurse into subdirectories
#' @return tibble with bound and standardized rows
read_hub_forecast_dir <- function(directory, recursive = TRUE) {
  stopifnot(dir.exists(directory))
  csv_files <- list.files(directory, pattern = "\\.csv$", recursive = recursive, full.names = TRUE)
  if (length(csv_files) == 0) return(tibble::tibble())
  purrr::map_dfr(csv_files, function(p) {
    df <- readr::read_csv(p, show_col_types = FALSE, progress = FALSE)
    standardize_forecast_df(df, file_path = p)
  })
}
