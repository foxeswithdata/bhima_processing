rm(list = ls())

library(tidyverse)
library(ggpubr)

Sys.setlocale("LC_ALL", "en_US.UTF-8")
figure_dir = "out/figures_publication/"

palette_colours <- c(
  "#006BA4", "#FF800E", "#ABABAB", "#595959", "#5F9ED1",
  "#C85200", "#898989", "#A2C8EC", "#FFBC79", "#CFCFCF"
)
# Seaborn "colorblind" palette — colorblind-safe, 10 categorical values
palette_colours <- c(
  "#000000", 
  "#0173B2", "#DE8F05", "#029E73", "#D55E00", "#CC78BC",
  "#CA9161", "#FBAFE4", "#949494", "#ECE133", "#56B4E9"
)

species <- c("All Species", "Dimorphocalyx lawianus", "Memecylon umbellatum", "Mangifera indica",
             "Olea dioica", "Syzygium cumini", "Litsea stocksii",
             "Lepisanthes tetraphylla", "Garcinia talbotii",
             "Syzygium gardneri", "Aglaia lawii")

palette_colours <- setNames(palette_colours, species)


forest_cells <- read.csv("data/plantfate_reruns/simulation_list.csv") %>%
  filter(biodiversity == "hb" & new_forest == TRUE)


species_data_out_all <- lapply(1:nrow(forest_cells), function(i){
  results_directory = paste("data/plantfate_reruns/individual_cell_simulations/GEB_step4_hb_af_10/cell_", 
                            forest_cells$cell[i],
                            "_hb/", 
                            sep = "")
  species_data_out = read.csv(paste(results_directory, "/Y_PFATE.csv", sep = ""))
  species_data_out$biodiversity <- "High"
  
  species_data_out$PID <- sapply(species_data_out$PID, function(spn){
    spn <- str_sub(spn, end = -3)
    return(spn)
  })
  
  species_data_out$cell <- forest_cells$cell[i]
  species_data_out$new_forest <- forest_cells$new_forest[i]
  return(species_data_out)
})

species_data_out_all <- plyr::rbind.fill(species_data_out_all) %>%
  select(c(YEAR, PID, TB, cell))
species_data_out_all$PID[species_data_out_all$PID == "Aglaia law"] <- "Aglaia lawii"
species_data_out_all$PID <- factor(species_data_out_all$PID, levels = species)

# species_data_out_all_totals <- species_data_out_all %>%
#   dplyr::group_by(YEAR, cell) %>%
#   summarise(TB = sum(TB))
# species_data_out_all_totals$PID = "All Species"
# species_data_out_all <- rbind(species_data_out_all, species_data_out_all_totals)

unique(species_data_out_all$PID)

p <- ggplot(species_data_out_all, aes(x = YEAR, y = TB, color = PID)) + 
  geom_line() +
  scale_color_manual("", values = palette_colours) +
  ggtitle(paste0("Total Biomass ","New Forest", " High Biodiversity", sep = "")) +
  facet_wrap("cell", nrow = 3) + 
  # scale_y_log10("Total Biomass [kgC]") +
  ylab(bquote("Total Biomass [kgC"*m^-2*"]")) + 
  guides(color = guide_legend(ncol = 4))+
  xlab("Date") +
  theme_bw() + 
  theme(legend.position = "bottom")
p

filename_figure = "figure_a10_total_biomass_new_forest_hb"
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = "figure_a10_total_biomass_new_forest_hb"
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")
