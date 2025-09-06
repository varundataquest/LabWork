# hubtools: Forecasting Hub Workflow Tools

A reusable R package that streamlines recurring Forecasting Hub workflows—data collection/standardization, visualization, evaluation, and dashboard integration—so contributors can produce consistent, high‑quality outputs with minimal manual effort.

## Features (mapped to project directions)

- Data collection & filtering (flu-metrocast–compatible)
  - `read_forecast_dir()`, `read_hub_forecast_dir()` and `standardize_forecast_df()` unify Forecast Hub CSVs.
  - `to_metrocast_schema()` and `read_metrocast_forecast_dir()` adapt metrocast-style folders.
- Visualization: observed vs forecasts (publication‑ready)
  - One‑line helpers: `plot_observed_vs_forecast()`, `plot_quantiles()`; dashboard wrappers `plot_dashboard_observed_vs_forecast()`, `plot_dashboard_quantiles()` with `theme_metrocast()`.
- Compare at flexible granularities (state/HSA/county/city)
  - Works over a generic `location` field. Use `load_crosswalk()` + `join_crosswalk()` to attach state/HSA/county/city labels.
- Interactive selection patterns
  - `filter_by_fix_date()` (fix issuance date → all horizons) and `filter_by_fix_horizon()` (fix horizon → multiple issuance dates).
- Multi-model evaluation (consistent metrics)
  - `evaluate_models()` (MAE/RMSE), `evaluate_wis()` and `evaluate_crps_from_quantiles()` for Forecast Hub scoring.
- Population & demographics utilities
  - `load_population_table()` and example crosswalk templates in `inst/extdata`.

## Installation (development)

```r
# In the project directory
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

# Interactive selections
f_issued <- filter_by_fix_date(forecasts, "2024-10-01")
f_h1     <- filter_by_fix_horizon(forecasts, 1)

# Plot: observed vs forecasts (publication-ready)
p <- plot_observed_vs_forecast(observed, f_issued, group_col = "model", facet_by = "location")
print(p)

# Evaluate models consistently
eval_results <- evaluate_models(eval_data)           # MAE/RMSE
wis_results  <- evaluate_wis(fc_quantiles, truth)    # WIS
crps_results <- evaluate_crps_from_quantiles(fc_quantiles, truth) # CRPS (from quantiles)
```

## Flexible granularities (state/HSA/county/city)

```r
# Attach human-readable labels via crosswalks
cw <- load_crosswalk("inst/extdata/crosswalk_county_fips.csv")  # headers included as a template
hub_df <- read_hub_forecast_dir("path/to/hub-forecasts")
hub_df_labeled <- join_crosswalk(hub_df, cw, by = c("location" = "fips"))
# Now facet by county/state label columns added from the crosswalk
```

## Metrocast integration

```r
# Standardize a directory of Forecast Hub CSVs (nested models allowed)
hub_df <- read_hub_forecast_dir("path/to/hub-forecasts")

# Metrocast-structured folders → unified schema
auto_df <- read_metrocast_forecast_dir("path/to/metrocast")

# Quantile ribbons with optional observed overlay
pq <- plot_dashboard_quantiles(hub_df, observed = observed)
print(pq)

# Build dashboard-ready tidy series and write CSV
series <- build_dashboard_series(observed, hub_df)
write_dashboard_series_csv(series, "dashboard_series.csv")
```

## GBM adapter (notebook outputs)

```r
# Reshape wide-by-quantile outputs to long unified schema
# expects columns like: location, target_date, q0.05, q0.25, q0.5, q0.75, q0.95
gbm_long <- adapt_gbm_quantiles(gbm_wide, model_name = "gbm")
```

## References

- Flu Metrocast Hub: https://github.com/reichlab/flu-metrocast
- Metrocast Dashboard: https://github.com/reichlab/metrocast-dashboard
- GBM notebook (City-Level-Forecasting): https://github.com/donga0223/City-Level-Forecasting/blob/main/epiENGAGE-GBQR/code/GBM_ED_TX_pct.ipynb

## Development

- R version: 4.4+
- Run tests: `devtools::test()`
- Build docs: `devtools::document()`
- Full check: `devtools::check()`

## License

MIT + file LICENSE
