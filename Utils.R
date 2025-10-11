#' Latitude, Longitude to Distance (KM)
#' @description
#' `latlng_to_distance_km` converts from 2 latlngs
#'  to distance using Haversine formula.
#' @param lat1: Latitude of the first location
#' @param lon1: Longitude of the first location
#' @param lat2: Latitude of the second location
#' @param lon2: Longitude of the second location
#' @return distance or NA if any provided values are NA
latlng_to_distance_km <- function(lat1, lon1, lat2, lon2) {

  if (any(is.na(c(lat1, lon1, lat2, lon2)))) return(NA_real_)

  r <- 6378.1  # Radius of earth in km
  to_rad <- pi / 180

  dlat <- (lat2 - lat1) * to_rad
  dlon <- (lon2 - lon1) * to_rad

  lat1r <- lat1 * to_rad
  lat2r <- lat2 * to_rad

  a <- sin(dlat / 2)^2 + cos(lat1r) * cos(lat2r) * sin(dlon / 2) ^ 2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))

  r * c
}