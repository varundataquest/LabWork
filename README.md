# hubtools: Forecasting Hub Workflow Tools

Utilities for data collection, visualization, and evaluation for Forecasting Hub-style workflows, compatible with flu-metrocast.

## Installation (development)

```r
# In the project directory
# install.packages("devtools")
devtools::load_all()
```

## Quick start

```r
library(hubtools)

# Read forecasts
# forecasts <- read_forecast_dir("path/to/forecasts")

# Filter
# f_issued <- filter_by_fix_date(forecasts, "2024-10-01")
# f_h1 <- filter_by_fix_horizon(forecasts, 1)

# Plot
# p <- plot_observed_vs_forecast(observed, f_issued, group_col = "model", facet_by = "location")
# print(p)

# Evaluate models
# results <- evaluate_models(eval_data)
```
