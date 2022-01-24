findBounds <- function(t, s) {
  
  if (!(st_is(t, "POLYGON"))) stop("t must be a POLYGON")
  if (!any(st_is(s, "LINESTRING"))) stop("s must contain only LINESTRING geometries")
  
  tract_streets <- s %>%
    st_filter(t)
  
  tract_line <- st_cast(t, "MULTILINESTRING")
  tract_buffer <- st_buffer(tract_line, dist = 5)
  
  streets_buffer <- tract_streets %>% 
    group_by(streetname) %>%
    summarise() %>%
    st_cast("LINESTRING") %>%
    st_buffer(dist = 1) %>% 
    mutate(area = st_area(geometry))
  
  intersection <- st_intersection(streets_buffer, tract_buffer) %>%
    st_make_valid()
  
  bounding_streets <- intersection %>%
    # Find how much of the intersected area remains of the original geometry area
    mutate(i_area = as.numeric(st_area(geometry)),
           pct_area = as.numeric(i_area/area)) %>%
    filter(pct_area > .3) %>%
    pull(streetname)
  
  street_bounds <- tract_streets %>%
    filter(streetname %in% bounding_streets) %>%
    distinct(streetname, .keep_all = T) %>%
    group_by(ewns_split = ifelse(ewns_dir %in% c("S", "N"),  "North-South", "East-West")) %>%
    # Identify streets by which side of tract it bounds
    mutate(
      "side" = case_when(
        ewns_split == "East-West" & ewns == max(ewns) ~ "East",
        ewns_split == "East-West" & ewns == min(ewns) ~ "West",
        ewns_split == "North-South" & ewns == max(ewns) ~ "North",
        ewns_split == "North-South" & ewns == min(ewns) ~ "South",
        max(ewns) == min(ewns) ~ "No Opposite Bound",
        TRUE ~ "Additional Side"
      )) %>% 
    # Arrange streets and complete missing so order is always NSEW
    select(side, pre_dir, street_nam, street_typ) %>% 
    filter(side %in% c("North", "South", 
                       "East", "West")) %>% 
    mutate("side" = factor(side, levels = c("North", "South", 
                                            "East", "West"))) %>% 
    tidyr::complete(side) %>% 
    arrange(side) %>% 
    # Create text string
    mutate(
      "ewns_text" = paste0(
        str_to_title(side), " - ", 
        str_replace_na(str_to_title(pre_dir), ""), " ",
        str_replace_na(str_to_title(street_nam), ""), " ",
        str_replace_na(str_to_title(street_typ), ""))
    ) %>%
    pull(ewns_text)
  
  street_bounds <- list(street_bounds)
  
  return(street_bounds)
}
