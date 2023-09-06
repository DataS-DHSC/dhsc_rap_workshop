library(onsr)
library(dplyr)
library(stringr)
library(readr)

load_data <- function(){

  # read in info on ONS datasets and display
  datasets <- ons_datasets()
  print(datasets$id)

  # select a dataset
  job_ads <- ons_get(id = "online-job-advert-estimates")

  # print columns
  print(colnames(job_ads))

  # print job types
  print(unique(job_ads$AdzunaJobsCategory))

  # remove NAs, filter by job category, filter to 2022
  health_jobs <- job_ads %>%
    filter(!is.na(v4_1)) %>%
    filter(AdzunaJobsCategory == "Healthcare and Social care") %>%
    filter(Time == 2022)

  # extract week number and sort by
  health_jobs_sorted <- health_jobs %>%
    mutate(week_no = str_extract(Week, "[0-9]+")) %>%
    mutate(week_no = as.numeric(week_no)) %>%
    arrange(week_no)

  # save data to csv
  write_csv(
    health_jobs_sorted,
    file = "./output/health_jobs_data.csv"
  )

}
