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

# NOTE: This may not work in Dataspell (No graph is plotted),
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

# NOTE: Can't load the graph in DataSpell so exporting it to png
ggsave(
  paste(plot_directory, "ride_length_vs_distance.png"),
  plot,
  width = 8,
  height = 6,
  dpi = 150
)
