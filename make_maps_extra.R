library(raster)
library(tidyverse)
library(sf)
library(terra)
library(gtools)
library(ggpubr)

set.seed(0110)

figure_dir = "out"

data_gpkg_region <- sf::read_sf("data/maps/region.gpkg")
data_gpkg_region_2d <- st_zm(data_gpkg_region$geom)

ggplot() + 
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  # geom_sf(data = data_gpkg_2d, fill = "grey") +
  # geom_sf(data = data_gpkg_intersected_2d, fill = "forestgreen") + 
  # geom_sf(data = data_gpkg_intersected_out_2d, fill = "lightgreen") + 
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25))

useclass_gpkg <- rast("data/maps/land_use_classes.tif")

## Forest area is under 0 so we make everything else NA
current_forest2 <- sf::read_sf("out/current_forest.shp")

ggplot() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_sf(data = current_forest2, fill = "forestgreen", lwd = 0) + 
  # geom_tile(data = clipped_raster_df, aes(x = x, y = y, fill = "landsurface/land_use_classes")) +
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25)) +
  guides(fill="none")

data_gpkg <- sf::read_sf("data/maps/junnar_potential_CFR.gpkg")
data_gpkg_2d <- st_zm(data_gpkg$geom)

# Extract forests only in modelled area

intersected_CFRS <- st_intersects(data_gpkg_region_2d, data_gpkg_2d)

data_gpkg_intersected_2d <- data_gpkg_2d[intersected_CFRS[[1]]]
data_gpkg_intersected_out_2d <- st_intersection(data_gpkg_region_2d, data_gpkg_2d)

ggplot() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") +
  geom_sf(data = data_gpkg_2d, fill = "grey") +
  # geom_sf(data = data_gpkg_intersected_2d, fill = "forestgreen") +
  geom_sf(data = data_gpkg_intersected_out_2d, fill = "lightgreen") +
  scale_x_continuous(limits = c(73.5, 74.05)) +
  scale_y_continuous(limits = c(18.95, 19.25))


forest_areas <- st_area(data_gpkg_intersected_out_2d)
total_area = sum(forest_areas)

area_percentage = 1
total_area_aim = total_area * area_percentage

forest_areas_perm_ind <- permute(1:length(forest_areas))
forest_areas_perm <- forest_areas[forest_areas_perm_ind]
forest_areas_perm_cumsum <- cumsum(forest_areas_perm)
ind_out <- forest_areas_perm_ind[forest_areas_perm_cumsum <= total_area_aim]

data_gpkg_intersected_out_2d_subset <- data_gpkg_intersected_out_2d[ind_out]

sum(st_area(data_gpkg_intersected_out_2d_subset)) / 10000

p <- ggplot() + 
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_sf(data = current_forest2, fill = "forestgreen", lwd = 0) + 
  geom_sf(data = data_gpkg_intersected_out_2d_subset, fill = "purple", color= "purple") + 
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25)) +
  theme_bw()
p

filename_figure = paste("map_total_afforestation", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("map_total_afforestation", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")


area_percentage_aim = c(0.2, 0.4, 0.6, 0.8, 1.0)
names_file = c("02", "04", "06", "08", "1")
total_area_aim = total_area * area_percentage_aim


lapply(1:5, function(x){
  ind_out <- forest_areas_perm_ind[forest_areas_perm_cumsum <= total_area_aim[x]]
  data_gpkg_intersected_out_2d_subset <- data_gpkg_intersected_out_2d[ind_out]
  st_write(data_gpkg_intersected_out_2d_subset, paste0(c("out/forest_", names_file[x], ".gpkg"), collapse = ""))
})


data_gpkg_forest_02 <- sf::read_sf("out/forest_02.gpkg")
forest_02 <- st_zm(data_gpkg_forest_02$geom)

data_gpkg_forest_04 <- sf::read_sf("out/forest_04.gpkg")
forest_04 <- st_zm(data_gpkg_forest_04$geom)

data_gpkg_forest_06 <- sf::read_sf("out/forest_06.gpkg")
forest_06 <- st_zm(data_gpkg_forest_06$geom)

data_gpkg_forest_08 <- sf::read_sf("out/forest_08.gpkg")
forest_08 <- st_zm(data_gpkg_forest_08$geom)

data_gpkg_forest_1 <- sf::read_sf("out/forest_1.gpkg")
forest_1 <- st_zm(data_gpkg_forest_1$geom)


plot_02 <- ggplot() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_sf(data = current_forest2, fill = "forestgreen", lwd = 0) + 
  geom_sf(data = forest_02, fill = "purple", color= "purple") + 
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25)) +
  labs(title = "20 % afforestation", hjust = 0.5)+
  theme(plot.title = element_text(hjust = 0.5))+
  theme_bw()
plot_02

plot_04 <- ggplot() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_sf(data = current_forest2, fill = "forestgreen", lwd = 0) + 
  geom_sf(data = forest_04, fill = "purple", color= "purple") + 
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25)) +
  labs(title = "40 % afforestation", hjust = 0.5)+
  theme(plot.title = element_text(hjust = 0.5))+
  theme_bw()
plot_04

plot_06 <- ggplot() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_sf(data = current_forest2, fill = "forestgreen", lwd = 0) + 
  geom_sf(data = forest_06, fill = "purple", color= "purple") + 
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25)) +
  labs(title = "60 % afforestation", hjust = 0.5)+
  theme(plot.title = element_text(hjust = 0.5))+
  theme_bw()
plot_06

plot_08 <- ggplot() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_sf(data = current_forest2, fill = "forestgreen", lwd = 0) + 
  geom_sf(data = forest_08, fill = "purple", color= "purple") + 
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25)) +
  labs(title = "80 % afforestation", hjust = 0.5)+
  theme(plot.title = element_text(hjust = 0.5))+
  theme_bw()
plot_08

plot_1 <- ggplot() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_sf(data = current_forest2, fill = "forestgreen", lwd = 0) + 
  geom_sf(data = forest_1, fill = "purple", color= "purple") + 
  scale_x_continuous(limits = c(73.5, 74.05)) + 
  scale_y_continuous(limits = c(18.95, 19.25)) +
  labs(title = "100 % afforestation", hjust = 0.5)+
  theme(plot.title = element_text(hjust = 0.5))+
  theme_bw()
plot_1

afforestation_plots <- ggarrange(plot_02, plot_04, plot_06, plot_08, plot_1,
                                 ncol = 2, nrow = 3)

afforestation_plots
# ggsave(plot = afforestation_plots, filename = "../out/plots/afforestation_maps.png", 
#        height = 8.06, width = 9.73)

filename_figure = paste("map_potential_afforestation", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = afforestation_plots, device = NULL, path = NULL,
       scale = 1, width = 190, height = 200, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("map_potential_afforestation", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = afforestation_plots, device = NULL, path = NULL,
       scale = 1, width = 190, height = 200, dpi = 300, limitsize = TRUE,
       units =  "mm")


### Map evaluated plantFATE sites


forest_cells <- read.csv("test_plantFATE_out/data/simulation_list.csv")
forest_cells <- unique(select(forest_cells, c("new_forest", "cell")))

cell_locations_new <- read.csv("data/afforestation_new_10_cells.csv")
cell_locations_existing <- read.csv("data/afforestation_10_cells.csv")

cell_locations <- rbind(cell_locations_new, cell_locations_existing)

locations_joined <- left_join(forest_cells, cell_locations, by="cell")

p <- ggplot() + 
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  geom_sf(data = current_forest2, fill = "forestgreen", lwd = 0) + 
  geom_sf(data = data_gpkg_intersected_out_2d_subset, fill = "purple", color= "purple") + 
  geom_point(data = locations_joined, aes(x = x, y = y, color = new_forest)) + 
  scale_colour_manual("New Forests", values = c("deeppink", "cyan")) +
  geom_text(data = locations_joined, aes(x = x+0.025, y = y+0.01, label = cell), col = 'black', family = 'firasans',
    size = 2.25
  ) +
  scale_x_continuous("",limits = c(73.5, 74.05)) +
  scale_y_continuous("",limits = c(18.95, 19.25)) +
  theme_bw()
p

filename_figure = paste("map_total_afforestation", "test_plantfate", "labels", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("map_total_afforestation", "test_plantfate",  "labels",sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")




map_data_country <- map_data('world')[map_data('world')$region == "Maharashta",]

ggplot() +
  # ## First layer: worldwide map
  # geom_polygon(data = map_data("world"),
  #              aes(x=long, y=lat, group = group),
  #              color = '#9c9c9c', fill = '#f3f3f3') +
  # ## Second layer: Country map
  geom_polygon(data = map_data_country,
               aes(x=long, y=lat, group = group),
               color = '#4d696e', fill = '#8caeb4') +
  
  coord_map() +
  geom_sf(data = data_gpkg_region_2d, fill = "lightgrey") + 
  # ggtitle(paste0("A map of ", country)) +
  scale_x_continuous(n.breaks = 20) +
  scale_y_continuous(n.breaks = 20) +
  theme_bw()



