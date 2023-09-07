library(ggplot2)

plot_data <- function(df){

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

  # save the plot
  ggsave("./output/health_gdp_chart.svg",
           height = 5,
           width = 10,
           units="in",
           dpi=300)

}


