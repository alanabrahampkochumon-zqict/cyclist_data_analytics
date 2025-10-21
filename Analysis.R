#' ### ANALYSIS ###
### HOUSEKEEPING ###
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("hexbin")
install.packages("gridExtra")

# Load the libraries required for analysis and data importing
library(readr)
library(ggplot2)
library(dplyr)
require(gridExtra)

plot_directory <- "Plots/"

# Load the cleaned dataset into memory
data_frame <- read.csv("./Data/Cleaned_Data_14_10_2025.csv")
data_frame <- data_frame |> select(-"X")

# NOTE: geom_point will work in Dataspell (No graph is plotted),
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

# The data was getting plotted in alphabetical order
# Added factoring to fix that
data_frame$ride_length_cat <- factor(
  data_frame$ride_length_cat,
  levels = c(
    "0 - 5", "5 - 10", "10 - 15", "15 - 30", "30 - 45", "45 - 60", "60+"
  )
)

# Lets see the distribution in a chart
plot <- data_frame |>
  group_by(member_casual, ride_length_cat) |>
  summarise(count = n()) |>
  ggplot(aes(x = ride_length_cat, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Number of Rides vs Ride Duration (Members vs Casual)",
    x = "Ride Duration (mins)",
    y = "Number of Rides"
  )
plot # Graph is not heavy, it renders
ggsave(
  paste(plot_directory, "casual_riders_vs_members__ride_length.png"),
  plot,
  width = 8,
  height = 6,
  dpi = 150
)
# We can observe that the casual members dominate 30+ minute ride
# This could mean that members use bike routine commutes
# while casuals use them for leisure

# Adding a factor to days of the week for correct visualization
# Kept weekends last to easily cluster and see weekday vs weekend
data_frame$start_day_of_week <- factor(
  data_frame$start_day_of_week,
  levels = c(
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  )
)

# We can further analyze the data to confirm
# if the rides are popular during weekdays or weekends
data_frame |>
  group_by(member_casual, start_day_of_week) |>
  summarise(count = n()) |>
  ggplot(aes(x = start_day_of_week, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Number of Riders vs Day of Week (Members vs Casual)",
    x = "Day of Week",
    y = "Number of Rides"
  )

# We can see that the usage is more distributed for members
# while casual rides tend to increase day by day until Saturday
# and shows a small drop on Sunday
# The higher rides on Weekends suggests that casual riders use bikes
# for leisure

# We can now explore months to understand whether casual riders are only pooled
# During certain months like vacation, or whether weather has an influence
data_frame |>
  mutate(month_name = factor(
    month.name[month],
    levels = month.name,
    ordered = TRUE
  )) |>
  group_by(member_casual, month_name) |>
  summarise(count = n()) |>
  ggplot(aes(x = month_name, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Number of Riders vs Month of year (Members vs Casual)",
    x = "Day of Week",
    y = "Number of Rides"
  )
# We can see an rides lower rides during winter months (Dec - Feb)
# But it increases from there and peaks during summer months,
# particularly August, which are vacation months
# Although member rides also fall, we can see more consistnet member rides,
# suggesting members usually use bike for commute

# Housekeeping: To preserve order, we need to add factoring to `time_of_day`
data_frame$time_of_day <- factor(
  data_frame$time_of_day,
  levels = c(
    "Mid Morning",
    "Late Morning",
    "Early Afternoon",
    "Late Afternoon",
    "Evening",
    "Night",
    "Late Night"
  )
)

# Now we can compare ride distribution during various hours of the day
data_frame |>
  group_by(member_casual, time_of_day) |>
  summarise(count = n()) |>
  ggplot(aes(x = time_of_day, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Ride Distribution during various time frame",
    x = "Time of Day",
    y = "Number of Rides"
  )
# We can see that the rides, both for casuals and members
# increase throughout the day, with both rides dipping after evening

# Graphing each hour to see if our theory members using the bikes for commute
# Work or Gym is on point
data_frame |>
  group_by(member_casual, start_hour) |>
  summarise(count = n()) |>
  ggplot(aes(x = start_hour, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Ride Distribution during Different Hour of the Day",
    x = "Hour of Day",
    y = "Number of Rides"
  )

# FIXED: Data Discrepency caused by TZ mismatch
data_frame$started_at <- with_tz(
  data_frame$started_at, tzone = "America/Chicago"
)
data_frame$ended_at <- with_tz(
  data_frame$ended_at, tzone = "America/Chicago"
)
data_frame$start_hour <- hour(data_frame$started_at)
data_frame |> write.csv("Data/Cleaned_Data_14_10_2025.csv")

# Let's the commute theory even further by filtering and separating
# Weekdays vs weekends
weekend_plot <- data_frame |>
  filter(start_day_of_week != "Saturday" & start_day_of_week != "Sunday") |>
  group_by(member_casual, start_hour) |>
  summarise(count = n()) |>
  ggplot(aes(x = start_hour, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Hourly Ride Distribution (Weekdays)",
    x = "Hour of Day",
    y = "Number of Rides"
  )
weekday_plot <- data_frame |>
  filter(start_day_of_week == "Saturday" | start_day_of_week == "Sunday") |>
  group_by(member_casual, start_hour) |>
  summarise(count = n()) |>
  ggplot(aes(x = start_hour, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Hourly Ride Distribution (Weekends)",
    x = "Hour of Day",
    y = "Number of Rides"
  )
grid.arrange(weekend_plot, weekday_plot, nrow = 2)
