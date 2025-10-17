#' ### ANALYSIS ###
### HOUSEKEEPING ###
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("hexbin")

# Load the libraries required for analysis and data importing
library(readr)
library(ggplot2)
library(dplyr)

plot_directory <- "Plots/"

# Load the cleaned dataset into memory
data_frame <- read.csv("./Data/Cleaned_Data_14_10_2025.csv")
data_frame <- data_frame |> select(-c("X"))

# NOTE: geom_point work in Dataspell (No graph is plotted),
# But it will work in RStudio
# You can export the graph as png though
plot <- ggplot(data_frame, aes(x = distance_rode_km, y = ride_length)) +
  geom_point() +
  scale_y_log10() +
  labs(
    x = "Distance (KM)",
    y = "Ride Length (minutes)",
    title = "Ride Length vs Distance - Outlier Check"
  )
# Lots of clustering near zero km mark
# NOTE: Can't load the graph in DataSpell so exporting it to png
ggsave(
  paste(plot_directory, "ride_length_vs_distance_5.8m_samples.png"),
  plot,
  width = 8,
  height = 6,
  dpi = 150
)

data_frame |>
  filter(distance_rode_km < 1 & ride_length > 60) |>
  nrow()
# Rides lengths that are less than 1km in distance and 60 mins in ride
# around 25k which is only 0.43% of the entire datasets
# so not removing it since, it wont drastically change the data analysis outcome

#' ### BEGIN Analysis ###
# Let's start by analysing the mean and median length of ride for
# Casual vs members
ride_summary <- data_frame |>
  group_by(member_casual) |>
  summarise(
    mean_distance = mean(distance_rode_km),
    median_distance = median(distance_rode_km),
    mean_duration = mean(ride_length),
    median_duration = median(ride_length),
    total_rides = n(),
  )
# The distance is around the same, but casual rides tends to be more longer
# with more riders being members

# Lets see the distribution in a chart
plot <- data_frame |>
  filter(member_casual == "casual") |>
  ggplot(aes(x = ride_length_cat)) +
  geom_bar() +
  labs(
    title = "Ride Duration vs Type of Rider",
    x = "Ride Duration",
    y = "Member vs Casual"
  )
ggsave(
  paste(plot_directory, "ride_duration_vs_casual_member.png"),
  plot,
  width = 8,
  height = 6,
  dpi = 150
)