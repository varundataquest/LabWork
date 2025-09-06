# Crosswalk and population utilities

#' Load a crosswalk CSV (e.g., FIPS to names, HSA mappings)
#'
#' @param path Path to a CSV file
#' @return tibble crosswalk
load_crosswalk <- function(path) {
  readr::read_csv(path, show_col_types = FALSE) %>% tibble::as_tibble()
}

#' Join a crosswalk into a data table by key
#'
#' @param df Data table to enrich
#' @param cw Crosswalk table
#' @param by Named vector specifying join key mapping, e.g., c("location" = "fips")
#' @param keep_all Whether to keep unmatched rows (left join)
#' @return tibble enriched with crosswalk columns
join_crosswalk <- function(df, cw, by, keep_all = TRUE) {
  df <- as_tibble_safe(df)
  cw <- as_tibble_safe(cw)
  if (keep_all) dplyr::left_join(df, cw, by = by) else dplyr::inner_join(df, cw, by = by)
}
