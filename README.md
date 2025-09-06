# hubtools: Forecasting Hub Workflow Tools

A reusable R package that streamlines recurring Forecasting Hub workflows—data collection/standardization, visualization, evaluation, and dashboard integration—so contributors can produce consistent, high‑quality outputs with minimal manual effort.

## Features

- **Data collection & standardization (flu-metrocast–compatible)**
  - `read_forecast_dir()`, `read_hub_forecast_dir()` and `standardize_forecast_df()` help ingest and unify Forecast Hub CSVs.
  - `to_metrocast_schema()` and `read_metrocast_forecast_dir()` adapt common schemas to a consistent set of columns.
- **Visualization: observed vs forecasts**
  - `plot_observed_vs_forecast()` line overlays; `plot_quantiles()` ribbons for 5–95 and 25–75 with median line.
  - Dashboard-friendly wrappers: `plot_dashboard_observed_vs_forecast()`, `plot_dashboard_quantiles()` with `theme_metrocast()`.
- **Interactive selection patterns (simple helpers)**
  - `filter_by_fix_date()` (fix issuance date → show all horizons)
  - `filter_by_fix_horizon()` (fix horizon → show forecasts issued on multiple dates)
- **Multi-model evaluation**
  - `evaluate_mae()`, `evaluate_rmse()`, and `evaluate_models()` for consistent metrics across models/horizons/time.
- **Population & demographics utilities**
  - `load_population_table()` for easy access to population tables at requested granularities.
- **Adapters and IO**
  - `remap_columns_first_match()`, `build_dashboard_series()` produce tidy series for dashboards.
  - `adapt_gbm_quantiles()` reshapes wide-by-quantile GBM outputs to a unified long schema.
  - `write_dashboard_series_csv()` and `read_dashboard_series_csv()` for dashboard CSV formats.

## Installation (development)

```r
# From the project directory
# install.packages("devtools")
devtools::load_all()
# Or build/install locally
# devtools::document(); devtools::install()
```

## Quick start

```r
library(hubtools)

# Read forecasts from a directory of CSVs
forecasts <- read_forecast_dir("path/to/forecasts")

# Filter by issuance date or horizon
f_issued <- filter_by_fix_date(forecasts, "2024-10-01")
f_h1     <- filter_by_fix_horizon(forecasts, 1)

# Plot observed vs forecasts
# observed must have: location, target_date, value
p <- plot_observed_vs_forecast(observed, f_issued, group_col = "model", facet_by = "location")
print(p)

# Evaluate models
# eval_data should have columns: model, observed, predicted
results <- evaluate_models(eval_data)
```

## Forecast Hub integration

```r
# Standardize a directory of Forecast Hub CSVs (nested models allowed)
hub_df <- read_hub_forecast_dir("path/to/hub-forecasts")

# Metrocast-structured folders → unified schema
auto_df <- read_metrocast_forecast_dir("path/to/metrocast")

# Quantile ribbons with optional observed overlay
pq <- plot_quantiles(hub_df, observed_data = observed)
print(pq)
```

## Metrocast dashboard series

```r
# Build dashboard-ready tidy series and write CSV
series <- build_dashboard_series(observed, hub_df)
write_dashboard_series_csv(series, "dashboard_series.csv")

# Read back later
series2 <- read_dashboard_series_csv("dashboard_series.csv")
```

## GBM adapter (notebook outputs)

```r
# Reshape wide-by-quantile outputs to long unified schema
# expects columns like: location, target_date, q0.05, q0.25, q0.5, q0.75, q0.95
gbm_long <- adapt_gbm_quantiles(gbm_wide, model_name = "gbm")
```

## Metrocast integration vignette

A step-by-step vignette is available at `vignettes/metrocast-integration.Rmd`:
- Read and standardize forecasts
- Plot observed vs forecasts and quantile ribbons
- Build dashboard series CSV for downstream apps

## Development

- R version: 4.4+
- Run tests: `devtools::test()`
- Build docs: `devtools::document()`
- Full check: `devtools::check()`

## License

MIT + file LICENSE
