set.seed(0110)


simulation_list_out = "test_plantFATE_out/data/simulation_list.csv"
num_sims_per_setting = 10


biodiversity = c("lb", "hb")
new_forest = c(TRUE, FALSE)
afforestation_new_fn = "data/afforestation_new_10_cells.csv"
afforestation_fn = "data/afforestation_10_cells.csv"
afforestation_new = read_csv(afforestation_new_fn)
afforestation = read_csv(afforestation_fn)

data_gpkg_region <- sf::read_sf("data/maps/region.gpkg")
data_gpkg_region_2d <- st_zm(data_gpkg_region$geom)

colnames(afforestation) <- c("cell", "X", "Y")
points.sf <- st_as_sf(afforestation, coords = c("X","Y"))
points.sf <- points.sf %>% st_set_crs(st_crs(data_gpkg_region_2d))

cells_subset <- st_filter(points.sf, data_gpkg_region_2d)
cells_subset <- as.data.frame(cells_subset)
afforestation_sub <- afforestation[afforestation$cell %in% cells_subset$cell,]


forest_cells_existing = afforestation_sub$cell[sample(1:nrow(afforestation_sub), num_sims_per_setting)]
forest_cells_new = afforestation_new$cell[sample(1:nrow(afforestation_new), num_sims_per_setting)]



simulation_list = data.frame(biodiversity = rep(biodiversity, times = (num_sims_per_setting * 2)),
                             new_forest = c(rep(TRUE, num_sims_per_setting * 2), 
                                            rep(FALSE, num_sims_per_setting * 2)),
                             cell = c(rep(forest_cells_new, each=2),
                                      rep(forest_cells_existing, each=2)))
write.csv(simulation_list, simulation_list_out)
