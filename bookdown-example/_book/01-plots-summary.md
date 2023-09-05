# Intro to plotting and calculating summary statistics

This page will take you through the steps of reading, filtering and saving data. Then we will plot the data and generate summary statistics. The final stage will be an exercise to test your knowledge. 

## Reading in data

To obtain the data needed for this exercise, we use the onsr package, which reads in data using the ONS API. We'll be using data on online job adverts. 

ONS gives the following information on this dataset:

"Adzuna is an online job search engine who collate information from thousands of different sources in the UK. These range from direct employers’ websites to recruitment software providers to traditional job boards thus providing a comprehensive view of current online job adverts. Adzuna is working in partnership with ONS and have made data available for analysis including online advert job descriptions, job titles, job locations, job categories and salary information. The data provided are a point-in-time estimate of all job adverts indexed in Adzuna’s job search engine during the point of data extraction.

These indices are created based upon job adverts provided by Adzuna. This data includes information on several million job advert entries each month, live across the UK, broken down by job category and UK countries and English regions."

```
# read in info on ONS datasets and display
datasets <- ons_datasets()
print(datasets$id)

# select a dataset
job_ads <- ons_get(id = "online-job-advert-estimates")
```

## Filtering data

We will use the package dplyr to clean the data and filter for last year's Health and Social care jobs data. We can then extract week number as a number to allow plotting the data to be straightforward. 

```
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
```

Once we have a cleaned dataset, we save as a csv. 

```
# save data to csv
write_csv(
  health_jobs_sorted,
  file = "./output/health_jobs_data.csv"
```

## Plotting data

Now we will plot the data using the package ggplot2. 

We read in the csv:

```
health_jobs_sorted = read_csv("./output/health_jobs_data.csv")
```
Set up the plot

```
# plot

ggplot() +
  DHSCcolours::theme_dhsc() +
  geom_line(
    data = health_jobs_sorted,
    aes(week_no, v4_1, colour = AdzunaJobsCategory),
    linewidth = 1
  ) +
  theme(legend.position="none") +
  DHSCcolours::scale_colour_dhsc_d() +
  labs(
    title = "Healthcare and Social care job adverts",
    subtitle = "2022",
    x = "Week number",
    y = "Value")
```

```
# save the plot
ggsave("./output/health_jobs_chart.svg",
         height = 5,
         width = 10,
         units="in",
         dpi=300)
```

![alt text](health_jobs_chart.svg)


## Generating summary stats

Finally, we will generate some summary statistics of the dataset.

We read in the data:

```
health_jobs_sorted = read_csv("./output/health_jobs_data.csv")
```

We calculate key stats and then filter on the maxiumum and minimum values to find which week these occcured in:

```
# get stats

minimum <- min(health_jobs_sorted$v4_1)
maximum <- max(health_jobs_sorted$v4_1)
average <- mean(health_jobs_sorted$v4_1)
median <- median(health_jobs_sorted$v4_1)

stats = list("minimum" = min(health_jobs_sorted$v4_1),
             "maximum"= max(health_jobs_sorted$v4_1))

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
```

