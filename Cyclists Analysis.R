### ASK ###
# Business Question (WHY): How can Cyclistic convert more casual riders into annual members?

# Subquestions to query (Examples)
# 1. Do casual riders take longer or shorter ride than members?
# 2. Are casual riders more active on weekends vs weekdays?
# 3. Are they concentrated in certain months or stations (seasonality or location patterns)?
# 4. What time of day do members vs casual riders prefer?

### HOUSEKEEPING ###
install.packages("tidyverse")

### PREPARE ###
# Load the libraries required for analysis and data importing
library(dplyr)
library(readr)
library(janitor)
library(lubridate)
library(tidyr)

# Read the filenames in the Data directory
directory <- "./Data"
files <- list.files(directory)

# Read the files and store it in a dataframe
data_frame_raw <- data.frame()
for (filename in files) {
  data_frame_raw <- rbind(data_frame_raw, read_csv(paste(directory, filename, sep = "/")))
}

# View the summary of the data frame
glimpse(data_frame_raw)
dim(data_frame_raw)
View(data_frame_raw)

### PROCESS ###
# Now let's clean the data
# 2. Run clean_names to clean the column names
data_frame_cleaned <- data_frame_raw |> clean_names()

# 1. Get the number of minutes for each ride
data_frame_cleaned <- data_frame_raw |>
  mutate(ride_length=difftime(ended_at, started_at, unit="mins")) |>
  mutate(ride_length=as.numeric(ride_length)) |>
  mutate(ride_length_cat=cut(ride_length, breaks = c(0, 5, 10, 15, 30, 45, 60, Inf), labels = c("0 - 5", "5 - 10", "10 - 15", "15 - 30", "30 - 45", "45 - 60", "60+"))) |>
  mutate(start_day_of_week=strftime(started_at, format = "%A")) |>
  mutate(month=strftime(started_at, format = "%m"))

# --------FUNCTION START----------
# Function that converts from latlng delta to distance using Haversine formula
latlng_to_distance_km <- function(lat1, lon1, lat2, lon2) {
  if (any(is.na(c(lat1, lon1, lat2, lon2)))) return(NA_real_)
  R <- 6378.1  # km
  to_rad <- pi / 180
  dlat <- (lat2 - lat1) * to_rad
  dlon <- (lon2 - lon1) * to_rad
  lat1r <- lat1 * to_rad
  lat2r <- lat2 * to_rad
  a <- sin(dlat/2)^2 + cos(lat1r) * cos(lat2r) * sin(dlon/2)^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  return(R * c)
}
latlng_to_distance_km_v <- Vectorize(latlng_to_distance_km) # Function needs to be vectorized to be used in mutate (multiple inputs)
### TEST CODE ###
latlng_to_distance_km(41.881, -87.623, 41.891, -87.623)  # ~1.1 km north-south
latlng_to_distance_km(41.881, -87.623, 41.881, -87.623)  # 0
london <- c(51.5074, -0.1278)
new_york <- c(40.7128, -74.0060)
r_dis_rounded_km <- 5500
latlng_to_distance_km(london[1], london[2], new_york[1], new_york[2])
### TEST CODE END ###
# --------FUNCTION END----------

# Convert each latlng delta in the data to distance in KM and store as an attribute
data_frame_cleaned <- data_frame_cleaned |>
  mutate(distance_rode_km=latlng_to_distance_km_v(end_lat, end_lng, start_lat, start_lng))

# Add a start time (day, night, early morning...) categorization to the data
data_frame_cleaned <- data_frame_cleaned |>
  mutate(start_hour=strftime(started_at, "%H")) |>
  mutate(start_hour=as.numeric(start_hour)) |>
  mutate(time_of_day=case_when(
    start_hour >= 0 & start_hour < 5  ~ "Late Night",
    start_hour >=5 & start_hour < 9 ~ "Late Morning",
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

# Create a new data frame with latlng and their respective station names
# Changelog 10-10-2025T05:45:00 : Include Station ID, as same latlng can return different stations
station <- rbind(
  data_frame_raw |>
  select(start_lat, start_lng, start_station_name, start_station_id) |>
  rename(lat=start_lat, lng=start_lng, station_name=start_station_name, station_id=start_station_id) |>
  drop_na() |>
  distinct(),
  data_frame_raw |>
  select(end_lat, end_lng, end_station_name, end_station_id) |>
  rename(lat=end_lat, lng=end_lng, station_name=end_station_name, station_id=end_station_id) |>
  drop_na() |>
  distinct()
)

# Helper function
# UNUSED: We cannot determine station from LatLng alone, but all station that have no names has not id either
get_station_name <- function(lat, lng) {
  # NOTE: The station data frame needs to be load
  # The function will not work independently of the data frame
  if (is.data.frame(station)) {
    print("station data frame is not loaded, please load it")
    return(NA)
  }
  return(
    station |>
      filter(lat=lat, lng=lng) |>
      pull(station_name)
  )
}

head(data_frame_cleaned)
glimpse(data_frame_cleaned)