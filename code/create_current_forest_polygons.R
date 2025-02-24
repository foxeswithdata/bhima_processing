rm(list = ls())

options(stringsAsFactors = FALSE)
library(raster)
library(tidyverse)
library(inborutils)
library(sf)
library(terra)
library(gtools)

data_gpkg_region <- sf::read_sf("data/maps/region.gpkg")
data_gpkg_region_2d <- st_zm(data_gpkg_region$geom)

ggplot() + 
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25))


useclass_gpkg <- rast("data/maps/land_use_classes.tif")

## Forest area is under 0 so we make everything else NA
x <- clamp(useclass_gpkg, upper=0.5, value=FALSE)

clipped_raster <- mask(x, data_gpkg_region)

# describe(clipped_raster)
# 
# class(clipped_raster)
summary(values(clipped_raster))

clipped_raster_df <- as.data.frame(clipped_raster, xy = TRUE)

summary(clipped_raster_df)

ggplot() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_tile(data = clipped_raster_df, aes(x = x, y = y, fill = "landsurface/land_use_classes")) +
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25)) +
  guides(fill="none")


useclass_gpkg <- raster("data/maps/land_use_classes.tif")
clipped_raster <- mask(useclass_gpkg, data_gpkg_region)

current_forest <- rasterToPolygons(clipped_raster, fun = function(x){x == 0}, na.rm = TRUE, dissolve = TRUE)

raster::shapefile(current_forest, "out/current_forest.shp")


current_forest2 <- sf::read_sf("out/current_forest.shp")

ggplot() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_sf(data = current_forest2, fill = "forestgreen", lwd = 0) + 
  # geom_tile(data = clipped_raster_df, aes(x = x, y = y, fill = "landsurface/land_use_classes")) +
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25)) +
  guides(fill="none")


st_is_valid(current_forest2)
