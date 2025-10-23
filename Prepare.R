# Install the required packages
install.packages("tidyverse")

# Load the packages
library(readr)

# Global Configuration
raw_data_directory <- "./RawData"
processed_data_directory <- "./Data"
uncleaned_data_filename <- "TripData_Uncleaned_20251023.csv"

# Get a list of all csv files in the data directory
files <- list.files(raw_data_directory)

# Read the files and store it in a dataframe
data_frame <- data.frame()
for (filename in files) {
  if (endsWith(filename, ".csv"))
    data_frame <- rbind(
      data_frame,
      read_csv(paste(raw_data_directory, filename, sep = "/"))
    )
}

# Create a directory if it doesn't exist
if (!dir.exists(processed_data_directory)) {
  dir.create(processed_data_directory)
}

# Write out the file as a single CSV
data_frame |>
  write.csv(
    paste(processed_data_directory, uncleaned_data_filename, sep = "/")
  )