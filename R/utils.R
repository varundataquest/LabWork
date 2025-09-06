# Utility helpers for hubtools

#' Ensure that required columns exist in a data frame
#'
#' @param data_table A data.frame or tibble
#' @param required_columns Character vector of required column names
#' @noRd
require_columns <- function(data_table, required_columns) {
  missing_columns <- setdiff(required_columns, colnames(data_table))
  if (length(missing_columns) > 0) {
    rlang::abort(paste0(
      "Missing required columns: ", paste(missing_columns, collapse = ", ")
    ))
  }
  invisible(TRUE)
}

#' Coerce to tibble safely
#' @noRd
as_tibble_safe <- function(x) {
  if (inherits(x, "tbl_df")) return(x)
  tibble::as_tibble(x)
}
