# Life Expectancy analysis

if (!require(openxlsx)) install.packages('openxlsx')
library(openxlsx)

# URL to download data from
data_most_recent_url <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/healthandsocialcare/healthinequalities/datasets/healthstatelifeexpectanciesbyindexofmultipledeprivationimdenglandallages/current/hslebyimdallages.xlsx"
data_prev_url <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/healthandsocialcare/healthinequalities/datasets/healthstatelifeexpectanciesbyindexofmultipledeprivationimdenglandallages/current/previous/v4/hsleallagesimd19.xlsx"

# Load data
df_data1 = read.xlsx(data_most_recent_url, sheet = 2, startRow = 5)
df_data1 <- df_data1[-c(1:13)]
df_data2 <- read.xlsx(data_prev_url, sheet = 2, startRow = 5)
df_data2 <- df_data2[-c(1:11)]

# Some data cleaning
df_data1 <- df_data1 %>% fill(Period, Decile, Sex)
df_data2 <- df_data2 %>% fill(Period, Decile, Sex)
names(df_data2) <- names(df_data1)

#Concatenate data
df_data <- rbind(df_data1, df_data2)

#Split the df up by age
filter_by_age <- function(data, a, name) {
  name <- filter(df_data, Agegroup == a)
}

# Filter by age and group by Sex
for (a in unique(df_data$Agegroup)) {
  str <- gsub('[[:punct:] ]+', '', a)
  name <- paste("df_data_grouped_by_sex",str, sep="_")
  filtered_data <- filter_by_age(df_data, a, name)
  grouped_data <- filtered_data %>%
    group_by(Sex) %>%
    summarise(mean_le = mean(`Life.Expectancy.(LE)`))
  assign(name, grouped_data)
}

# Filter by age and group by decile
for (a in unique(df_data$Agegroup)) {
  str <- gsub('[[:punct:] ]+', '', a)
  name <- paste("df_data_grouped_by_decile",str, sep="_")
  filtered_data <- filter_by_age(df_data, a, name)
  grouped_data <- filtered_data %>%
    group_by(Decile) %>%
    summarise(mean_le = mean(`Life.Expectancy.(LE)`))
  assign(name, grouped_data)
}


