# Quick note before starting
# I didn't exclude all na values (station -> 20% of dataset),
# as I thought it may provide insight for answering business question,
# especially if removing the dataset can skew particular insights
# by removing data from a particular month

### HOUSEKEEPING ###
install.packages("tidyverse")

# Load the libraries required for analysis and data importing
library(readr)
library(ggplot2)
library(dplyr)

# Load the cleaned dataset into memory
data_frame <- read.csv("./Data/cleaned_dataset.csv")

# Just to refresh our memory, view the dataset
glimpse(data_frame)

# It seems we have a new "X" column (that stores the index)
# which we will need to drop
data_frame <- data_frame |> subset(select = -c(X))

# Before diving into analysis, let's check if there are any rides to
# short to be considered a ride, less than 1 min or distance less of 0
# NOTE: These should have been done in the "PROCESS" phase
data_frame |> filter(distance_rode_km == 0) |> dim()
data_frame |> filter(ride_length < 1) |> dim()
data_frame |>
  filter(
    distance_rode_km > 1 & ride_length < 1
  ) |>
  summary()

# Calculate the percentage of rides that are too short to be considered a ride
invalid_ride_length <- data_frame |>
  filter(distance_rode_km == 0 | ride_length < 1) |>
  dim()

invalid_ride_length[1] / dim(data_frame)[1] * 100 # 6% of the rides are invalid

summary(data_frame$ride_length)
data_frame |> filter(ride_length >= 1) |>  select(ride_length) |> summary()
# Stats are not much affected after dropping those values
data_frame |> filter(ride_length < 1) |> count(member_casual, rideable_type)
# More than 99% of the data with less than 1 min ride_length, and
# distance 0 are from electric bikes impling that they are due to small
# relocations that don't actually contribute to being actual rides

# Drop the rides
valid_rides <- data_frame |> filter(distance_rode_km > 0 & ride_length >= 1)

# Data quantification
# Total Rides
total_rides <- valid_rides |> nrow() # 5,837,410 rides

# Rider distribution before
data_frame |>
  group_by(member_casual) |>
  summarise(mean = n() * 100 / nrow(data_frame), riders = n())
# Rider distribution after dropping off invalid riders
valid_rides |>
  group_by(member_casual) |>
  summarise(mean = n() * 100 / total_rides, riders = n())
# The distribuion remains the same with a delta of around 1%

# Average Ride Length
data_frame |>
  select(ride_length) |>
  summary()
valid_rides |>
  select(ride_length) |>
  summary()

# Disovering new outliers
# When doing post clean i found some rides that are
# greater than 500 mins and have less than 2 or 3 km recorded
# So let's remove them
valid_rides <- valid_rides |>
  filter(!(distance_rode_km < 3 & ride_length > 360))
valid_rides |> summary()

# Write to external file
write.csv(valid_rides, "Data/Cleaned_Data_14_10_2025.csv")