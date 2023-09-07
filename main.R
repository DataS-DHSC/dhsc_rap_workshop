
# Project launch file
# Source this file to run code

# Load global packages ----------------------------------------------------

# check librarian package management installed
if (!requireNamespace("librarian")) install.packages("librarian", quiet = TRUE)

# use suppress to prevent build warnings
# note can install from github
suppressWarnings(
  librarian::stock(
    DataS-DHSC/DHSClogger,
    DataS-DHSC/DHSCtools,
    DataS-DHSC/DHSCcolours,
    yaml, tidyverse,
    tools, fs,
    curl, httr, polite, rvest,
    tidyxl, unpivotr, writexl, lubridate,
    ggrepel, scales, sf, svglite,
    quiet = TRUE
  )
)

# Setup logging -----------------------------------------------------------
logger <- DHSClogger::get_dhsc_logger()
# set threshold of console log to information and above
logger$set_threshold("log.console", "INFO")

# Call main code ----------------------------------------------------------
logger$info("[Begin]")

# add source of run script and entry point to code below
source("./R/02_filter_data.R", local = TRUE)
source("./R/03_example_plot_data.R", local = TRUE)
source("./R/04_example_summary_stats.R", local = TRUE)
source("./R/01_download.R", local = TRUE)

# read in configuration
config_path <- file.path("input", "config.yml")
config <- yaml::read_yaml(config_path)

#run functions to pull in and analyse data
df <- download_ons_data(config)
filtered_df <- filter_data(df)
plot_data(filtered_df)
summary_stats(filtered_df)

logger$info("[End]")
