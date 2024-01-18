
# Project launch file
# Source this file to run code


# Load global packages ----------------------------------------------------

# check librarian package management installed
if (!requireNamespace("librarian")) install.packages("librarian", quiet = TRUE)

librarian::shelf(logger, httr, dplyr, readr, jsonlite)

# use suppress to prevent build warnings
# note can install from github
suppressWarnings(librarian::stock(DataS-DHSC/DHSClogger))


# Setup logging -----------------------------------------------------------

logger <- DHSClogger::get_dhsc_logger()

# set threshold of console log to information and above
logger$set_threshold("log.console", "INFO")


# Call main code ----------------------------------------------------------

logger$info("[Begin]")

# load config
config_path <- file.path("input", "config.yml")
config <- yaml::read_yaml(config_path)

# print the config file details
print(config)

# add source of run script and entry point to code below
source("./R/log_example.R", local = T)
source("./R/download_data.R", local = T)
data <- download_ons_data(config)

logger$info("[End]")
