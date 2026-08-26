rm(list = ls())

library(tidyverse)
library(ggpubr)
library(MASS)

Sys.setlocale("LC_ALL", "en_US.UTF-8")
figure_dir = "out/figures_publication/"

library(scico)
## Prepare outputs for figures
palette_colours = scico(7, palette = "hawaii")


forest_cells <- read.csv("data/plantFATE_rerun_data/simulation_list.csv") %>%
  filter(new_forest == FALSE & biodiversity == "hb")


community_data_out_all <- lapply(1:nrow(forest_cells), function(i){
  results_directory = paste("out/PlantFATE_reruns_out/individual_cell_simulations/GEB_step4_",
                            forest_cells$biodiversity[i],
                            "_af_10/cell_", 
                            forest_cells$cell[i],
                            "_",
                            forest_cells$biodiversity[i],
                            sep = "")
  print(results_directory)
  community_data_out = read.csv(paste(results_directory, "/D_PFATE.csv", sep = ""))
  community_data_out$biodiversity <- ifelse(forest_cells$biodiversity[i] == "hb", "High", "Low")
  
  community_data_out$cell <- forest_cells$cell[i]
  community_data_out$new_forest <- forest_cells$new_forest[i]
  community_data_out$Date <- as.Date(paste(community_data_out$IYEAR, 
                                           community_data_out$MON, 
                                           community_data_out$DAY, sep = "-"))
  return(community_data_out)
})

community_data_out_all <- plyr::rbind.fill(community_data_out_all) %>%
  dplyr::select(c(Date, MORT, SWP, cell, biodiversity))


## Make into a kernel density

get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}

community_data_out_all$density <- get_density(community_data_out_all$SWP, community_data_out_all$MORT, n = 100)


p <- ggplot(community_data_out_all, aes(x = SWP, y = MORT, color = density)) + 
  geom_point() +
  scale_color_scico("Density", palette = 'acton') +
  ggtitle(paste0("Mortality Against Soil Water Potential", sep = "")) +
  # scale_y_log10("Total Biomass [kgC]") +
  ylab(bquote("Mortality Rate [kgC"*m^-2*"da"*y^-1*"]")) + 
  xlab("Soil Water Potential [MPa]") +
  theme_bw()
# theme(legend.position = "bottom")
p



filename_figure = "figure_a13_mortality_existing_forests_hb"
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = "figure_a13_mortality_existing_forests_hb"
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")



p <- ggplot(community_data_out_all, aes(x = SWP, y = MORT, color = density)) + 
  geom_point() +
  scale_color_scico("Density", palette = 'acton') +
  ggtitle(paste0("Mortality Against Soil Water Potential", sep = "")) +
  facet_wrap("cell", nrow = 3) +
  # scale_y_log10("Total Biomass [kgC]") +
  ylab(bquote("Mortality Rate [kgC"*m^-2*"da"*y^-1*"]")) + 
  xlab("Soil Water Potential [MPa]") +
  theme_bw()
# theme(legend.position = "bottom")
p



filename_figure = "figure_a13_mortality_existing_forests_hb"
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = "figure_a13_mortality_existing_forests_hb"
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

