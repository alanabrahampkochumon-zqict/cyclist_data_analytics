# Install Necessary Packages
install.packages("tidyverse")
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
    max_distance_km = max(distance_rode_km),
    min_distance_km = min(distance_rode_km),
    mean_distance_km = mean(distance_rode_km),
    sd_distance_km = sd(distance_rode_km),
    median_distance_km = median(distance_rode_km)
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

# Ride Frequency by month
print(
  data_frame |>
    group_by(member_casual, month) |>
    summarise(total_rides = n()) |>
    mutate(percentage = total_rides / sum(total_rides) * 100),
  n = 24
)
# This further confirms our theory that rides peak during
# August, both for members (22.5%) and casuals (28.4%)

# Average ride distance by hour
print(
  data_frame |>
    group_by(member_casual, start_hour) |>
    summarise(mean_duration = mean(ride_length)),
  n = 48
)
# This data shows that casual riders travel more distance
# on average than members


# Summary of Ride Type used among members vs casuals
data_frame |>
  group_by(member_casual, rideable_type) |>
  summarise(
    percentage = n() / nrow(data_frame) * 100
  )
# 14.5% of casuals use classic bike, whereas 25.5% of member use them
# Electric bikes share a similar story, with members taking the lead
# with a share of 37.6% compared to 22.4%

# Ride Frequency by Day of Week
data_frame |>
  group_by(member_casual, start_day_of_week) |>
  summarise(rides = n()) |>
  arrange(member_casual, desc(rides))
# We can see that causal riders peak during Weekends (Saturday and Sunday)
# While members peaks during weekdays with weekends rides being the lowest

