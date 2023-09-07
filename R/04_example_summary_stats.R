library(dplyr)

#get summary stats

summary_stats <- function(df){

  # get stats

  minimum <- min(df$v4_1)
  maximum <- max(df$v4_1)
  average <- mean(df$v4_1)

  stats = list("minimum" = minimum,
               "maximum"= maximum)

  # get week values for stats, print

  for (name in names(stats)) {
    stat_value = stats[[name]]

    year_val <- df %>%
      filter(v4_1 == stats[[name]]) %>%
      select(Time) %>%
      pull

    print(paste("the ",name, "value is", stat_value, "(year:", year_val, ")"))
  }

  print(paste("the average value is",round(average,1)))

}


