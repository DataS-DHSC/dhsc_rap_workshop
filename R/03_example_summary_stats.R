library(readr)
library(dplyr)

health_jobs_sorted = read_csv("./output/health_jobs_data.csv")

#get summary stats

summary_stats <- function(){

  # get stats

  minimum <- min(health_jobs_sorted$v4_1)
  maximum <- max(health_jobs_sorted$v4_1)
  average <- mean(health_jobs_sorted$v4_1)
  median <- median(health_jobs_sorted$v4_1)

  stats = list("minimum" = minimum,
               "maximum"= maximum)

  # get week values for stats, print

  for (name in names(stats)) {
    stat_value = stats[[name]]

    week_no <- health_jobs_sorted %>%
      filter(v4_1 == stats[[name]]) %>%
      select(week_no) %>%
      pull

    print(paste("the ",name, "value is", stat_value, "(week:", week_no, ")"))
  }

  print(paste("the average value is",round(average,1)))
  print(paste("the median value is",round(median)))

}


