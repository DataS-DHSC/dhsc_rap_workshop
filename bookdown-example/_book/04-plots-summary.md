# Plotting and calculating summary statistics

This page will take you through the steps for the data analysis we wish to do. It will comprise of manipulating and plotting data and generating statistics. 

## Reading in the data

We start by reading in two libraries:

```
library(dplyr)
library(readr)
```

First, we can print the column names of the dataset and the unique industry types in the dataset. 

```
# print columns
print(colnames(df))

# print industry types
print(unique(df$UnofficialStandardIndustrialClassification))
```

## Filtering data

We will now clean the data and filter for data on the health and social care industry in England and by type of growth rate we wish to analyse. 

```
# remove NAs, filter by industry, geography and growth rate figure
health_gdp_time_series <- df %>%
  filter(!is.na(v4_1)) %>%
  filter(UnofficialStandardIndustrialClassification == "Q: Human health and social work activities") %>%
  filter(Geography == "England") %>%
  filter(GrowthRate == "Annual growth rate")
```
We can then set the year column as a number to allow plotting of the data to be straightforward. Note, the "v4_1" column are the values we will look to plot later. 

```
# set year as a number and sort by
health_gdp_time_series_sorted <- health_gdp_time_series %>%
  mutate(Time = as.numeric(Time)) %>%
  arrange(Time)
```

Once we have a cleaned dataset, we can save it as a csv for future use. 

```
# save data to csv
write_csv(
  health_gdp_time_series_sorted,
  file = "./output/health_gdp_time_series_sorted.csv")
```

## Plotting data

Now we will plot the data using ggplot2. 

We read in ggplot2:

```
library(ggplot2)
```

Here we set up the plot - reading in DHSC colours, plotting a line of the values and set the chart labels. 

```
# plot

ggplot(data = df,
       aes(Time,
           v4_1,
           colour = UnofficialStandardIndustrialClassification)) +
  DHSCcolours::theme_dhsc() +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  theme(legend.position="none") +
  DHSCcolours::scale_colour_dhsc_d() +
  labs(
    title = "Annual growth rate of Human health and social work activities, England",
    subtitle = "2023-2021",
    x = "Year",
    y = "Annual growth rate (%)") +
  scale_x_continuous(breaks=seq(2013,2021,1))
```
And save the plot

```
# save the plot
ggsave("./output/health_gdp_chart.svg",
         height = 5,
         width = 10,
         units="in",
         dpi=300)
```

It will look like this:

![alt text](health_gdp_chart.svg)


## Generating summary stats

Finally, we will generate some summary statistics of the dataset.

```
library(dplyr)
```

We calculate various stats:

```
# get stats

minimum <- min(df$v4_1)
maximum <- max(df$v4_1)
average <- mean(df$v4_1)
```

We then want to filter the dataset on the maximum and minimum values to find the year in which these occurred. 

We start by creating a list where the now already defined variables for maximum and minimum are mapped to a string, which we can print in the output i.e. set the max value to the string "maximum". 

We then loop over these values, retrieve the numerical value, filter on the dataset and pull the year figures out. We then print these values along with the average already calculated. 

```
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
```
This gives us some basic information about the dataset.

In the next section, you'll use these techniques to perform your own analysis on a different dataset, which you will then take on to generate into a RAP project.
