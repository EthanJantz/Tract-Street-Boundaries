library(dplyr)
library(sf)

# Tracts from Chicago Data Portal
# https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Census-Tracts-2010/5jrd-6zik
tracts <- read_sf(here::here("Data", "tracts_2010", "tracts.shp")) 

# Streets from Chicago Data Portal
# https://data.cityofchicago.org/Transportation/Street-Center-Lines/6imu-meau
streets <- read_sf(here::here("Data", "streets", "streets_chi.shp")) 

source(here::here("Scripts", "findBounds.R"))

# This will take a significant amount of time
for(tract in 1:nrow(tracts)) {
  print(paste0("Row ", tract, " of ", nrow(tracts)))
  t <- tracts[tract, ]
  bounds <- findBounds(t, streets)
  tracts$bounds[tract] <- bounds
}

# Convert list col to comma-separated string and save
tracts %>%
  mutate(bounds = map_chr(bounds, ~ .x %>% str_c(collapse = ", "))) %>%
  st_write(here::here("Output", "tracts_bounds.shp"))
