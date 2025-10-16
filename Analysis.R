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
  geom_hex() +
  scale_y_log10() +
  labs(
    x = "Distance (KM)",
    y = "Ride Length (minutes)",
    title = "Ride Length vs Distance - Outlier Check"
  )
# Lots of clustering near zero km mark

data_frame |>
  filter(distance_rode_km < 1 & ride_length > 60) |>
  nrow()
# Rides lengths that are less than 1km in distance and 60 mins in ride
# around 25k which is only 0.43% of the entire datasets
# so not removing it since, it wont drastically change the data analysis outcome

# NOTE: Can't load the graph in DataSpell so exporting it to png
ggsave(
  paste(plot_directory, "ride_length_vs_distance.png"),
  plot,
  width = 8,
  height = 6,
  dpi = 150
)
