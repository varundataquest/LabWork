# IO utilities for dashboard series

#' Write dashboard series tibble to CSV
#'
#' Ensures column order and writes without row names.
#'
#' @param series_tbl Tibble produced by build_dashboard_series or similar
#' @param path Output CSV path
#' @return Invisibly returns the path
write_dashboard_series_csv <- function(series_tbl, path) {
  cols <- c("location", "date", "value", "series", "model", "quantile")
  series_tbl <- as_tibble_safe(series_tbl)
  missing <- setdiff(cols, names(series_tbl))
  if (length(missing) > 0) {
    rlang::abort(paste0("Missing columns for dashboard series: ", paste(missing, collapse = ", ")))
  }
  series_tbl <- dplyr::select(series_tbl, dplyr::all_of(cols))
  readr::write_csv(series_tbl, path)
  invisible(path)
}

#' Read dashboard series CSV
#'
#' @param path Input CSV path
#' @return tibble with dashboard series columns
read_dashboard_series_csv <- function(path) {
  readr::read_csv(path, show_col_types = FALSE) %>% tibble::as_tibble()
}
