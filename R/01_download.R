# Load required packages --------------------------------------------------
library(tidyverse)
library(httr)
library(dplyr)
library(jsonlite)


# Function definitions ----------------------------------------------------
#' Download ONS data - retrieves ONS data using the ID specified in the config file
#'
#' @param config - contains I/O directory structure, ONS url and id for desired data
#'
#' @return ons_data as a dataframe
download_ons_data <- function(config) {

  # First I want to get a list of data made available via ONS API
  # - the URL for this dictionary is specified in the config file.
  # This isn't strictly needed for the exercise but it gives participants an
  # idea of the types of data available, so they can choose which dataset they
  # want to download
  path <- config$data_dictionary_url

  ret_code <- -1
  tryCatch(
    {
      request <- GET(url = path)
      ret_code <- 0
      },
    error = function(e){
      print(e)
      message(e)
      }
    )

  #check if an error reading, and if so return to calling function
  if(ret_code < 0) return(NULL)

  content <- rawToChar(request$content)
  content_flat <- fromJSON(content, flatten = TRUE)

  # create a dataframe with the downloaded data dictionary and save to csv
  # so I can see what data is available
  df <- data.frame(id = content_flat$items$id,
                   title = content_flat$items$title,
                   release_frequency = content_flat$items$release_frequency,
                   next_release = content_flat$items$next_release,
                   description = content_flat$items$description,
                   links_latest_versions = content_flat$items$links.latest_version.href,
                   links_self_href= content_flat$items$links.self.href,
                   qmi_href= content_flat$items$qmi.href)

  write.csv(df,
            paste0(config$output_dir, "/ons_api.csv"))

  # This is the start of the exercise.
  #
  # ONS data files have a unique identifier and this can be used to extract the
  # data. The id we are interested in is specified in the config file and so use
  # that to interrogate the data dictionary. In particular, we want to
  # extract the latest version, the url for which can be extracted from the
  # data dictionary - use the links_latest_versions field
  file_latest_version <- df %>%
    filter(id == config$data_id) %>%
    select(links_latest_versions) %>%
    pull()

  # Using the links_latest_versions we can get the meta data for the latest file
  # and this meta data includes the url for the latest file in either csv or xlsx
  # format. We choose .csv here -> extract it from downloads$csv$href

  ret_code <- -1
  tryCatch(
    {
      request <- GET(url = file_latest_version)
      ret_code <- 0
    },
    error = function(e){
      print(e)
      message(e)
    }
  )

  #check if an error reading, and if so return to calling function
  if(ret_code < 0) return(NULL)

  content <- rawToChar(request$content)
  content_flat <- fromJSON(content, flatten=TRUE)
  file_url <- content_flat$downloads$csv$href

  # Now we have the file url we can read it like any other file
  ret_code <- -1
  tryCatch(
    {
      df_data <- read.csv(file_url)
      ret_code <- 0
    },
    error = function(e){
      print(e)
      message(e)
    }
  )

  #check if an error reading, and if so return to calling function
  if(ret_code < 0) return(NULL)

  write.csv(df_data,
            paste0(config$output_dir,
                   "/",
                   config$data_id,
                   ".csv")
  )

  # print some basic data about the file e.g. row count and return the file
  # to the calling function.
  rowcount <- nrow(df_data)
  log_message <- sprintf("Number of rows downloaded for %s was: %d",
                         config$data_id,
                         rowcount)

  print(log_message)
  return(df_data)
}

