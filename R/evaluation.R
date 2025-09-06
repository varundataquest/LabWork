# Evaluation helpers for forecasts

#' Compute Mean Absolute Error (MAE)
#'
#' @param data Tibble with columns truth_col and pred_col
#' @param truth_col Column name for true/observed values
#' @param pred_col Column name for predicted/forecast values
#' @return numeric scalar MAE
#' @examples
#' # mae <- evaluate_mae(df, truth_col = "obs", pred_col = "pred")
evaluate_mae <- function(data, truth_col = "observed", pred_col = "predicted") {
  require_columns(data, c(truth_col, pred_col))
  truth_sym <- rlang::sym(truth_col)
  pred_sym <- rlang::sym(pred_col)
  mean(abs(dplyr::pull(data, !!truth_sym) - dplyr::pull(data, !!pred_sym)), na.rm = TRUE)
}

#' Compute Root Mean Squared Error (RMSE)
#'
#' @param data Tibble with columns truth_col and pred_col
#' @param truth_col Column name for true/observed values
#' @param pred_col Column name for predicted/forecast values
#' @return numeric scalar RMSE
#' @examples
#' # rmse <- evaluate_rmse(df, truth_col = "obs", pred_col = "pred")
evaluate_rmse <- function(data, truth_col = "observed", pred_col = "predicted") {
  require_columns(data, c(truth_col, pred_col))
  truth_sym <- rlang::sym(truth_col)
  pred_sym <- rlang::sym(pred_col)
  sqrt(mean((dplyr::pull(data, !!truth_sym) - dplyr::pull(data, !!pred_sym))^2, na.rm = TRUE))
}

#' Evaluate multiple models with provided metrics
#'
#' @param data Tibble containing at least columns: model_col, truth_col, pred_col
#' @param model_col Column name identifying the model
#' @param truth_col Column name for true/observed values
#' @param pred_col Column name for predicted/forecast values
#' @param metrics Named list of metric functions taking (data, truth_col, pred_col)
#' @return Tibble with one row per model and one column per metric
#' @examples
#' # results <- evaluate_models(df, metrics = list(mae = evaluate_mae, rmse = evaluate_rmse))
evaluate_models <- function(
  data,
  model_col = "model",
  truth_col = "observed",
  pred_col = "predicted",
  metrics = list(mae = evaluate_mae, rmse = evaluate_rmse)
) {
  require_columns(data, c(model_col, truth_col, pred_col))
  model_sym <- rlang::sym(model_col)

  data %>%
    dplyr::group_by(!!model_sym) %>%
    dplyr::group_modify(function(df, key) {
      tibble::tibble(!!!purrr::imap(metrics, function(fn, name) fn(df, truth_col, pred_col)))
    }) %>%
    dplyr::ungroup() %>%
    dplyr::rename(!!model_col := !!model_sym)
}
