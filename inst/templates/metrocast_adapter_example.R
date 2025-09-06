# Example: Metrocast integration template
# Fill in your paths and run step by step

library(hubtools)

# 1) Read forecasts
# hub_df <- read_hub_forecast_dir("/path/to/hub-forecasts")

# 2) Read observed data (must have columns: location, target_date/date, value)
# observed_df <- readr::read_csv("/path/to/observed.csv", show_col_types = FALSE)

# 3) Build dashboard series and write CSV
# series <- build_dashboard_series(observed_df, hub_df)
# write_dashboard_series_csv(series, "dashboard_series.csv")

# 4) Plot quicklooks
# p1 <- plot_dashboard_observed_vs_forecast(observed_df, hub_df, facet_by = "location")
# p2 <- plot_dashboard_quantiles(hub_df, observed = observed_df)
# print(p1); print(p2)
