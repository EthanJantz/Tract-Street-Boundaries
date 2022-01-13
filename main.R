library(dplyr)
library(sf)

tracts <- read_sf(here::here("Data", "tracts_2010", "tracts.shp")) # Tracts from Chicago Data Portal
streets <- read_sf(here::here("Data", "streets", "streets_chi.shp")) # Streets from Chicago Data Portal

source(here::here("Scripts", "findBounds.R"))

# This will take a significant amount of time
for(tract in 1:nrow(tracts)) {
  print(paste0("Row ", tract, " of ", nrow(tracts)))
  t <- tracts[tract, ]
  bounds <- findBounds(t, streets)
  tracts$bounds[tract] <- bounds
}

# Convert list col to comma-separated string and save
unnest(tracts, bounds) %>%
  st_write(here::here("Output", "tracts_bounds.shp"))
