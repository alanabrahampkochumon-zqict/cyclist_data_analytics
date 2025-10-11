### ASK ###
# Business Question (WHY):
# How can Cyclistic convert more casual riders into annual members?

# Subquestions to query (Examples)
# 1. Do casual riders take longer or shorter ride than members?
# 2. Are casual riders more active on weekends vs weekdays?
# 3. Are they concentrated in certain months or stations
#    (seasonality or location patterns)?
# 4. What time of day do members vs casual riders prefer?

### HOUSEKEEPING ###
install.packages("tidyverse")


#' ### PREPARE ###

# Load the libraries required for analysis and data importing
library(dplyr)
library(readr)
library(janitor)
library(lubridate)
library(tidyr)
source("Utils.R")

# Read the filenames in the Data directory
directory <- "./Data"
files <- list.files(directory)


#' CHANGELOG 11-10-2025T05:38:00
#'                            - Adding filtering for reading only csv files
# Read the files and store it in a dataframe
data_frame_raw <- data.frame()
for (filename in files) {
  if (endsWith(filename, ".csv"))
    data_frame_raw <- rbind(
      data_frame_raw,
      read_csv(paste(directory, filename, sep = "/"))
    )
}

# View the summary of the data frame
glimpse(data_frame_raw)
dim(data_frame_raw)
View(data_frame_raw)

#' ### PROCESS ###
#' Data Cleaning

# 1. Run clean_names to clean the column names
data_frame_cleaned <- data_frame_raw |> clean_names()

# 2. Get the number of minutes for each ride
data_frame_cleaned <- data_frame_cleaned |>
  mutate(ride_length = difftime(ended_at, started_at, unit = "mins")) |>
  mutate(ride_length = as.numeric(ride_length)) |>
  mutate(ride_length_cat = cut(
    ride_length,
    breaks = c(0, 5, 10, 15, 30, 45, 60, Inf),
    labels = c(
      "0 - 5", "5 - 10", "10 - 15", "15 - 30", "30 - 45", "45 - 60", "60+"
    )
  )
  ) |>
  mutate(start_day_of_week = strftime(started_at, format = "%A")) |>
  mutate(month = strftime(started_at, format = "%m"))

# 3. Convert and store the latlng to a distance
data_frame_cleaned <- data_frame_cleaned |>
  mutate(
    distance_rode_km = latlng_to_distance_km_v(
      end_lat, end_lng, start_lat, start_lng
    )
  )

# 4. Add a start time (day, night, early morning...) categorization to the data
data_frame_cleaned <- data_frame_cleaned |>
  mutate(start_hour=strftime(started_at, "%H")) |>
  mutate(start_hour=as.numeric(start_hour)) |>
  mutate(time_of_day = case_when(
    start_hour >= 0 & start_hour < 5  ~ "Late Night",
    start_hour >= 5 & start_hour < 9 ~ "Late Morning",
    start_hour >= 9 & start_hour < 12 ~ "Mid Morning",
    start_hour >= 12 & start_hour < 15 ~ "Early Afternoon",
    start_hour >= 15 & start_hour < 18 ~ "Late Afternoon",
    start_hour >= 18 & start_hour < 22 ~ "Evening",
    TRUE ~ "Night"
  )
  )

# View the dataset
glimpse(data_frame_cleaned)
head(data_frame_cleaned)
dim(data_frame_cleaned)


# Checking for Bias
# a. How much of the station information is missing
(
  sum(is.na(data_frame_cleaned$start_station_id)) / dim(data_frame_cleaned)[1]
) * 100
# Nearly 20% of Start Station are missing
(
  sum(is.na(data_frame_cleaned$end_station_id) / dim(data_frame_cleaned)[1])
) * 100
# Nearly 21% of End Stations are missing

# b. Is the missing station information uniformly spread depending rider type?
data_frame_cleaned |>
  mutate(
    start_station_missing = is.na(start_station_id) | is.na(start_station_name)
  ) |>
  group_by(member_casual) |>
  summarise(pct_missing = mean(start_station_missing) * 100, n = n())
# The data is evenly distributed among both members and casual riders


glimpse(data_frame_cleaned)