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
