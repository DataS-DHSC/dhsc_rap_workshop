# Downloading data

This page will take you through the steps for downloading data from a URL specified within a config file, and catching/logging any errors encountered. We will perform the following steps:

- download meta data describing what ONS data is available
- download meta data to get the URL for the latest release of your chosen ONS data
- download the latest release file.

We will then extract some summary statistics and print them to the console.

## Data setup and load ONS meta data

We start by reading in required libraries:

```
library(tidyverse)
library(httr)
library(dplyr)
library(jsonlite)
```

It is good practice to define parameters needed by your code in configuration files, because that means you don't have to touch the code when you need to change any parameter values.

In the DHSC Template, the main configuration file sits in the ./input directory and is called config.yml. 

The config file for this exercise contains the following parameter/settings:

```
data_dictionary_url: "https://api.beta.ons.gov.uk/v1/datasets"
data_id: "regional-gdp-by-year"
input_dir: ./input
output_dir: ./output
```

The first step, having made desired changes to the parameter values, is to load the contents of the config.yml file. This is done as follows:

```
# read in configuration
config_path <- file.path("input", "config.yml")
config <- yaml::read_yaml(config_path)

# print the config file details
print(config)
```
 
It should be noted that reading the config file is normally done in the top level main function, which then passes a reference to the file to any functions that need it. But in this instance we have loaded the config file ourselves, to illustrate how this can be done.

## Get a list of data that can be extracted using this ONS API

We pass the data_dictionary_url to a GET function to download a list of available data, and we then wrangle it before writing it to a .csv.

### error processing
We use tryCatch({ ... }) to capture any errors reading the URL (or for reading any other files or other Input/Output). If we did not have a tryCatch block, on encountering an error, the code automatically stops executing and passes the error to the function that called it. This carries on up the chain of calling functions until the error is either captured by a tryCatch block or the whole program fails, and the error is written to the console. By using tryCatch({...}) can intercept this process, and have more fine grained control over how we deal with the error:

- we can add addition information to the error message to help users narrow down where the problem lies
- we can choose to carry on executing the code if the error isn't catastrophic.

Normal usage is to wrap the call to get any I/O in the tryCatch {} block and then deal with the error in the error function. In this case we just print the message to the console but in later exercises you will see how error messages can be written to the output log.


```
  path <- config$data_dictionary_url

  ret_code <- -1
  tryCatch(
    {
      request <- GET(url = path) # see httr for more detail on this function
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
  content_flat <- fromJSON(content, flatten = TRUE) # use this jsonlite function to convert JSON data to an R object
  
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
                   
  print(df)

  # now write the data to an output file so you can check the data dictionary offline. Note how the 
  # output directory is a parameter in the config file.
  write.csv(df,
            paste0(config$output_dir, "/ons_api.csv"))
```
The data dictionary contents are shown below

![data dictionary](ons_api.jpg)

## Get the URL for the latest release of a specified ONS file

ONS data files have a unique identifier and this can be used to extract the data. The id we are interested in is specified in the config file and so use that to interrogate the data dictionary. In particular, we want to extract the latest version, the url for which can be extracted from the data dictionary -> links_latest_versions field

```
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
```

## Now we have the file url we can read it like any other file

```
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
```

## Print summary stats and finish
Note that the return statement has been commented out, but in normal circumstances we would return the file contents as a dataframe.

```
 rowcount <- nrow(df_data)
  log_message <- sprintf("Number of rows downloaded for %s was: %d",
                         config$data_id,
                         rowcount)

  print(log_message)
  # return(df_data) 
```

In the next section, you'll practice these techniques using a different ONS dataset.
