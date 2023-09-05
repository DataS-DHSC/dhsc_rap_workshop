library(readr)
library(ggplot2)

plot_data <- function(){

  health_jobs_sorted = read_csv("./output/health_jobs_data.csv")

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

  # save the plot
  ggsave("./output/health_jobs_chart.svg",
           height = 5,
           width = 10,
           units="in",
           dpi=300)

}


