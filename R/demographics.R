# Population and demographics utilities

#' Load a population table at a requested granularity
#'
#' This function loads a population table from a provided path or from a built-in
#' dataset located under `inst/extdata`. The expected columns are flexible, but
#' typically include identifiers such as location and a population value column.
#'
#' @param path Optional path to a CSV file. If omitted, will look for
#'        `system.file("extdata", "population.csv", package = "hubtools")`.
#' @return tibble with population data
#' @examples
#' # pop <- load_population_table()
#' # pop <- load_population_table("/path/to/population.csv")
load_population_table <- function(path = NULL) {
  if (is.null(path)) {
    default_path <- system.file("extdata", "population.csv", package = "hubtools")
    if (default_path == "") {
      rlang::abort("No built-in population.csv found. Please supply a path.")
    }
    path <- default_path
  }
  readr::read_csv(path, show_col_types = FALSE) %>% tibble::as_tibble()
}
