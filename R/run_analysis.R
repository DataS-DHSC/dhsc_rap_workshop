# Load required packages --------------------------------------------------
library(tidyverse)

# Source other scripts ----------------------------------------------------
download <- new.env(); source("./R/01_download.R", local = download)
filter_data <- new.env(); source("./R/02_filter_data.R", local = filter_data)
plot_data <- new.env(); source("./R/03_example_plot_data.R", local = plot_data)
summary_stats <- new.env(); source("./R/04_example_summary_stats.R", local = summary_stats)

# Main function to run analysis -------------------------------------------

#' Run analysis
#'
#' Main function used to run analysis. This function is called from
#' the main.R script which should be used to run the project.
#'
#' @export
#'
run_analysis <- function() {
  # log action
  logger$info("Running analysis...")

  # read in configuration
  config_path <- file.path("input", "config.yml")
  config <- yaml::read_yaml(config_path)

  # get file date and time stamp
  config$date_stamp <- format(Sys.time(), "%Y%m%d-%H%M")

  # get ONS data
  browser()
  ons_data <- download$download_ons_data(config)

  if(is.null(data)) {
    logger$error("Download failed")
    return(NULL)
  }

  # Filter, plot and summarise ONS data
  filtered_ons_data <- filter_data$filter_data(ons_data)
  plot_data$plot_data(filtered_ons_data)
  summary_stats$summary_stats(filtered_ons_data)
}
