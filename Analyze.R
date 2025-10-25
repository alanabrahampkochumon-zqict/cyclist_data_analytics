# Install Necessary Packages
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("gridExtra")
install.packages("modeest")

# Load the libraries
library(readr)
library(dplyr)
library(modeest)

# Global Variables
data_directory <- "./Data"
cleaned_data_filename <- "TripData_Cleaned_20251023.csv"

# Load the data
data_frame <- read.csv(
  paste(data_directory, cleaned_data_filename, sep = "/")
)

# Summary of Ride Lengths
data_frame |>
  group_by(member_casual) |>
  summarise(
    max_ride_length = max(ride_length),
    min_ride_length = min(ride_length),
    mean_ride_length = mean(ride_length),
    sd_ride_length = sd(ride_length),
    median_ride_length = median(ride_length)
  )
# We can see that members have a casuals
# have higher average ride length than members,
# with ride_length for causuals more spread out (sd of 42.4 vs 19.1)


# Summary of Ride Distance
data_frame |>
  group_by(member_casual) |>
  summarise(
    max_ride_length = max(distance_rode_km),
    min_ride_length = min(distance_rode_km),
    mean_ride_length = mean(distance_rode_km),
    sd_ride_length = sd(distance_rode_km),
    median_ride_length = median(distance_rode_km)
  )
# Both casual and members have similar average distance covered,
# with around the same spread

# Summary of Most Occupied months
data_frame |>
  group_by(member_casual) |>
  summarise(
    most_rode_hour = mlv(start_hour, method = "mfv"),
    most_rode_month = mlv(month, method = "mfv")
  )
# Rides Peak for both casuals and member during 5PM (17:00)
# and during the month of August (8)

# Summary of Ride Type used among members vs casuals
data_frame |>
  group_by(member_casual, rideable_type) |>
  summarise(
    percentage = n() / nrow(data_frame) * 100
  )
# 14.5% of casuals use classic bike, whereas 25.5% of member use them
# Electric bikes share a similar story, with members taking the lead
# with a share of 37.6% compared to 22.4%
