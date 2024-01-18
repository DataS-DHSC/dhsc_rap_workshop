
log_test <- function(){
  
  number_of_rows <- round(runif(n = 1, min = 1, max = 50))
  
  example_df <- data.frame(x = runif(n = number_of_rows, min = 1, max = 50),
                           y = runif(n = number_of_rows, min = 1, max = 50))
  
  log_message <- sprintf("Number of rows in the data: %d. Max value in column x: %f. Max value in column y: %f",
                         nrow(example_df),
                         max(example_df$x),
                         max(example_df$x))
              
  logger$info(log_message)
  
  return(example_df)
  
}



log_test()
