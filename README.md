# Finding Lines that Bound Polygons

This project is a tool I created to help solve a problem I was facing in working with some GIS data. The problem was as follows: Given a set of census tracts and street center lines, identify which streets form the boundaries of which tracts and to which side the streets are bounding. 

This problem was a bit more work than I had anticipated it would be, but the result does work. If you download the street center lines and census tracts data from the Chicago Data Portal you can run `main.R` and, after some time, receive an output `tracts_bounds.shp` file in the Output folder. This file is the same as the input folder, but includes a `bounds` column that lists all of the streets that bound the tract and which side they were on as a comma separated string. 

## Data

To run this, you'll need to download street center line and tract shapefiles. The tract shapefile can be _any_ polygon dataset, but the streets data must have identifiers for the street direction and coordinates.

If you just want to find which lines bound a polygon and don't care about the side they bound, you can probably mess with the `findBounds.R` script in the scripts folder without much hassle.