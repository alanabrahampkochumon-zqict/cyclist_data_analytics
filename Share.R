# Install Necessary Packages
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("gridExtra")

# Load the libraries
library(readr)
library(ggplot2)
library(dplyr)
library(gridExtra)

# Global Variables
data_directory <- "./Data"
cleaned_data_filename <- "TripData_Cleaned_20251023.csv"
graphs_directory <- "Graphs"
ride_duration_graph <- "casual_riders_vs_members__ride_duration.png"
day_dist_graph <- "casual_riders_vs_members__ride_day_distribution.png"
monthly_dist_graph <-
  "casual_riders_vs_members__ride_monthly_distribution.png"
daytime_cat_dist_graph <-
  "casual_riders_vs_members__ride_daytime_cat_distribution.png"
hourly_ride_dist_graph <-
  "casual_riders_vs_members__ride_hourly_distribution.png"
`hourly_ride_dist_comp_graph` <-
  "casual_riders_vs_members__weekend_weekday_ride_hourly_distribution.png"
rideable_type_dist_graph <-
  "casual_riders_vs_members__rideable_type_distribution.png"
rideable_type_dist_mc_graph <-
  "casual_riders_vs_members__rideable_type_member_casual_distribution.png"

# Load the data
data_frame <- read.csv(
  paste(data_directory, cleaned_data_filename, sep = "/")
)

# Factoring Data to ensure the data is shown in the correct order
data_frame$start_day_of_week <- factor(
  data_frame$start_day_of_week,
  levels = c(
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  )
)

data_frame$time_of_day <- factor(
  data_frame$time_of_day,
  levels = c(
    "Late Night",
    "Morning",
    "Late Morning",
    "Early Afternoon",
    "Late Afternoon",
    "Evening",
    "Night"
  )
)

data_frame$ride_length_cat <- factor(
  data_frame$ride_length_cat,
  levels = c(
    "0 - 5", "5 - 10", "10 - 15", "15 - 30", "30 - 45", "45 - 60", "60+"
  )
)

data_frame$month_name <- factor(
  data_frame$month_name,
  levels = month.name,
  ordered = TRUE
)

# The distance is around the same, but casual rides tends to be more longer
# with more riders being members

# Ride Duration and Distribution of Rides
# For Casual and Member Riders
plot <- data_frame |>
  group_by(member_casual, ride_length_cat) |>
  summarise(count = n()) |>
  ggplot(aes(x = ride_length_cat, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Number of Casual and Member Riders categorized by Ride Duration",
    x = "Ride Duration (minutes)",
    y = "Number of Rides"
  )
plot
ggsave(
  paste(graphs_directory, ride_duration_graph, sep = "/"),
  plot,
  width = 12,
  height = 7,
  dpi = 300
)
# We can observe that the casual members dominate 30+ minute ride
# This could mean that members use bike routine commutes
# while casuals use them for leisure

# We can further analyze the data to confirm
# if the rides are popular during weekdays or weekends
plot <- data_frame |>
  group_by(member_casual, start_day_of_week) |>
  summarise(count = n()) |>
  ggplot(aes(x = start_day_of_week, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Number of Casual and Member Riders categorized by Day of Week",
    x = "Day of Week",
    y = "Number of Rides"
  )
plot
ggsave(
  paste(graphs_directory, day_dist_graph, sep = "/"),
  plot,
  width = 12,
  height = 7,
  dpi = 300
)
# We can see that the usage is more distributed for members
# while casual rides tend to increase day by day until Saturday
# and shows a small drop on Sunday
# The higher rides on Weekends suggests that casual riders use bikes
# for leisure

# We can now explore months to understand whether casual riders are only pooled
# During certain months like vacation, or whether weather has an influence
plot <- data_frame |>
  group_by(member_casual, month_name) |>
  summarise(count = n()) |>
  ggplot(aes(x = month_name, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Number of Casual and Member Riders categorized by Month of Year",
    x = "Day of Week",
    y = "Number of Rides"
  )
plot
ggsave(
  paste(graphs_directory, monthly_dist_graph, sep = "/"),
  plot,
  width = 12,
  height = 7,
  dpi = 300
)
# We can see an rides lower rides during winter months (Dec - Feb)
# But it increases from there and peaks during summer months,
# particularly August, which are vacation months
# Although member rides also fall, we can see more consistnet member rides,
# suggesting members usually use bike for commute

# Now we can compare ride distribution during
# various hours (Categorized) of the day
plot <- data_frame |>
  group_by(member_casual, time_of_day) |>
  summarise(count = n()) |>
  ggplot(aes(x = time_of_day, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Ride Distribution during various daytime categories",
    x = "Time of Day",
    y = "Number of Rides"
  )
plot
ggsave(
  paste(graphs_directory, daytime_cat_dist_graph, sep = "/"),
  plot,
  width = 12,
  height = 7,
  dpi = 300
)
# We can see that the rides, both for casuals and members
# increase throughout the day, with both rides dipping after evening

# To get increased resolution
# Graphing each hour to see if our theory members using the bikes for commute
# Work or Gym is on point
plot <- data_frame |>
  group_by(member_casual, start_hour) |>
  summarise(count = n()) |>
  ggplot(aes(x = start_hour, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Ride Distribution during Different Hour of the Day",
    x = "Hour of Day",
    y = "Number of Rides"
  )
plot
ggsave(
  paste(graphs_directory, hourly_ride_dist_graph, sep = "/"),
  plot,
  width = 12,
  height = 7,
  dpi = 300
)
# We can see that the rides, both for casuals and members
# increase throughout the day, with both rides dipping after evening

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
plot <- grid.arrange(weekend_plot, weekday_plot, nrow = 2)
plot
ggsave(
  paste(
    graphs_directory,
    `hourly_ride_dist_comp_graph`,
    sep = "/"
  ),
  plot,
  width = 12,
  height = 7,
  dpi = 300
)
# More member rides use bike during weekdays
# to commute to work
# However, we can a lot of night rides during weekends, for both casual
# and members

# Finally let's explore the distribution of rideable types
# Among members and casuals
plot <- data_frame |>
  group_by(rideable_type, member_casual) |>
  summarise(count = n()) |>
  ggplot(aes(x = rideable_type, y = count, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Ride Distribution of Members and Casuals against Bike Type",
    x = "Ride Type",
    y = "Number of Rides"
  )
plot
ggsave(
  paste(
    graphs_directory,
    rideable_type_dist_graph,
    sep = "/"
  ),
  plot,
  width = 12,
  height = 7,
  dpi = 300
)
# Both ride types are used by members and casuals with members leading
# Electric bikes are preferred by both members and casuals



member_plot <- data_frame |>
  filter(member_casual == "member") |>
  group_by(rideable_type, start_day_of_week) |>
  summarise(count = n()) |>
  ggplot(aes(x = start_day_of_week, y = count, fill = rideable_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "Rideable Type used by members against day of week",
    x = "Start Day of Week",
    y = "Number of Rides"
  )

casual_plot <- data_frame |>
  filter(member_casual == "casual") |>
  group_by(rideable_type, start_day_of_week) |>
  summarise(count = n()) |>
  ggplot(aes(x = start_day_of_week, y = count, fill = rideable_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "Rideable Type used by casuals against day of week",
    x = "Start Day of Week",
    y = "Number of Rides"
  )
plot <- grid.arrange(member_plot, casual_plot, nrow = 2)
plot
ggsave(
  paste(
    graphs_directory,
    rideable_type_dist_mc_graph,
    sep = "/"
  ),
  plot,
  width = 12,
  height = 7,
  dpi = 300
)
# We can see that members use classic bike
# more or less consistently throughout the week
# But casuals use both classic and electric bikes
# during the weekend more, indicating further that
# Casuals use electric bikes for leisure
