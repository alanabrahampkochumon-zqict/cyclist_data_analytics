# Install necessary packages
install.packages("ggplot2")
install.packages("tidyverse")

# Load the packages
library(dplyr)
library(readr)
library(janitor)
library(lubridate)
library(tidyr)
library(ggplot2)
source("./Utils.R")

# Global Variables
data_directory <- "./Data"
uncleaned_data_filename <- "TripData_Uncleaned_20251023.csv"
cleaned_data_filename <- "TripData_Cleaned_20251023.csv"
graphs_directory <- "Graphs"
missing_station_percent_graph <- "missing_station_per_month_for_bike_type.png"

# Read the uncleaned data into a data frame
data_frame <- read.csv(
  paste(
    data_directory, uncleaned_data_filename, sep = "/"
  )
)

# View the dataframe to get an idea of the data contained
glimpse(data_frame)

# Cleaning the column names and dropping any non-distinct values
data_frame <- data_frame |> clean_names() |> distinct()

# Dropping unwanted columns
data_frame <- data_frame |> select(-c("x", "ride_id"))

# Make all the dates associated with Chicago Timezone
# for accurate time calculations
data_frame$started_at <- with_tz(
  data_frame$started_at, tzone = "America/Chicago"
)
data_frame$ended_at <- with_tz(
  data_frame$ended_at, tzone = "America/Chicago"
)

# Get the number of minutes for each ride
data_frame <- data_frame |>
  mutate(ride_length = difftime(ended_at, started_at, unit = "mins")) |>
  mutate(ride_length = as.numeric(ride_length)) |>
  mutate(ride_length_cat = cut(
    ride_length,
    breaks = c(0, 5, 10, 15, 30, 45, 60, Inf),
    labels = c(
      "0 - 5", "5 - 10", "10 - 15", "15 - 30", "30 - 45", "45 - 60", "60+"
    ),
    ordered_result = TRUE
  )
  )

# Add a start day of week column
# Day on which the ride started
data_frame <- data_frame |>
  mutate(start_day_of_week = strftime(started_at, format = "%A"))

# Separate the ride start month
data_frame <- data_frame |>
  mutate(month = as.numeric(strftime(started_at, format = "%m")))


# Add start month name for additional context
data_frame <- data_frame |>
  mutate(month_name = factor(
    month.name[month],
    levels = month.name,
    ordered = TRUE
  ))

# Convert the Latitude and Longitude Difference as Distance in KM
data_frame <- data_frame |>
  mutate(
    distance_rode_km = latlng_to_distance_km_v(
      end_lat, end_lng, start_lat, start_lng
    )
  )

# Categorize hours of the day as Morning, Afternoon etc.
data_frame <- data_frame |>
  mutate(start_hour = strftime(started_at, "%H")) |>
  mutate(start_hour = as.numeric(start_hour)) |>
  mutate(time_of_day = case_when(
    start_hour >= 0 & start_hour < 5  ~ "Late Night",
    start_hour >= 5 & start_hour < 9 ~ "Morning",
    start_hour >= 9 & start_hour < 12 ~ "Late Morning",
    start_hour >= 12 & start_hour < 15 ~ "Early Afternoon",
    start_hour >= 15 & start_hour < 18 ~ "Late Afternoon",
    start_hour >= 18 & start_hour < 22 ~ "Evening",
    TRUE ~ "Night"
  )
  )

### Bias Checking ###
# Checking if data should be dropped based on start station ids
(
  sum(is.na(data_frame$start_station_id)) / nrow(data_frame)
) * 100
# Nearly 20% of the dataset is missing a start station id
# Dropping may skew the dataset

# Is the missing station information uniformly spread depending rider type?
data_frame |>
  mutate(
    start_station_missing = is.na(start_station_id) | is.na(start_station_name)
  ) |>
  group_by(member_casual) |>
  summarise(
    station_missing_percent = mean(start_station_missing) * 100,
    n = n()
  )
# The data is evenly distributed among both members and casual riders

# c. Is the missing station information uniformly spread by bike(rideable) type
data_frame |>
  mutate(
    start_station_missing = is.na(start_station_id) | is.na(start_station_name)
  ) |>
  group_by(rideable_type) |>
  summarise(
    station_missing_percent = mean(start_station_missing) * 100,
    n = n()
  )
# It is not evenly distributed.
# 0% of classic bikes have missing location,
# 32.9% of electric bike have missing location, and
# 46.9% of electric scooters have missing location

plot <- data_frame |>
  mutate(
    start_station_missing = is.na(start_station_id) |
      is.na(start_station_name)
  ) |>
  group_by(rideable_type, month_name) |>
  summarise(
    station_missing_percent = mean(start_station_missing) * 100
  ) |>
  ggplot(
    aes(x = month_name, y = station_missing_percent, fill = rideable_type)
  ) +
  geom_col(position = "dodge") +
  labs(
    title = "Missing station per ride type for each month",
    x = "Months",
    y = "Station Missing (%)"
  )

ggsave(
  paste(graphs_directory, missing_station_percent_graph, sep="/"),
  plot,
  width = 12,
  height = 7,
  dpi = 300
)
# Electric Scooters are missing start station location
# at a rate of 25% - 35% per month
# Electric Scooters have even distribution of missing location,
# but only 2 months worth data is availabe