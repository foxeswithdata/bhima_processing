rm(list = ls())
library(tidyverse)
library(scico)

## Prepare outputs for figures
palette_colours = scico(7, palette = "hawaii")
palette_colours[7] = "#222222"
Sys.setlocale("LC_ALL", "en_US.UTF-8")

figure_dir = "out/figures_publication/"
dir.create(figure_dir, showWarnings = FALSE, recursive = TRUE)

## PROCESS BASIN WIDE AVERAGE - NOTE this is not normalized

## Read all the data 
dirs <- list.dirs(path = "data/ssp3_out", recursive = FALSE)
dirs <- dirs[grep("GEB_step4", dirs)]
dirs_df <- data.frame(dir = dirs,
                      biodiversity = c("na", rep(c("high", "low"), each = 6)),
                      afforestation = c("na", rep(c(0, 0.2, 0.4, 0.6, 0.8, 1), times  = 2)))

dfs <- lapply(1:nrow(dirs_df), function(m){
  out <- read.csv(paste0(dirs_df$dir[m], "/", "hydrology.soil/soil_moisture_weighted_mean_m.csv", sep = ""))
  out$biodiversity <- dirs_df$biodiversity[m]
  out$afforestation <- dirs_df$afforestation[m]
  return(out)
})

transpiration_average_yearly_basin <-bind_rows(dfs) %>%
  mutate(yr = year(date)) %>%
  group_by(yr, afforestation, biodiversity) %>%
  summarise(avg = mean(soil_moisture_weighted_mean_m))


transpiration_average_yearly_basin$afforestation[transpiration_average_yearly_basin$afforestation == "10.0"] <- "1.0"
transpiration_average_yearly_basin$afforestation[transpiration_average_yearly_basin$afforestation == "na"] <- "N/A" 
transpiration_average_yearly_basin$biodiversity[transpiration_average_yearly_basin$biodiversity == "high"] <- "GEB-PF High"
transpiration_average_yearly_basin$biodiversity[transpiration_average_yearly_basin$biodiversity == "low"] <- "GEB-PF Low"
transpiration_average_yearly_basin$biodiversity[transpiration_average_yearly_basin$biodiversity == "na"] <- "Default\nGEB"

transpiration_average_yearly_basin$biodiversity <- factor(transpiration_average_yearly_basin$biodiversity, levels = c("GEB-PF High", "GEB-PF Low", "Default\nGEB"))


p <- ggplot(transpiration_average_yearly_basin, aes(x = yr, y = avg,
                              linetype = biodiversity,
                              color = as.factor(afforestation))) +
  geom_line() +
  ggtitle(paste0("Average Basin Yearly Soil Moisture [m]",  sep = "")) +
  xlab("Year") +
  scale_color_manual("Afforestation\nLevel", values = palette_colours) +
  scale_linetype_discrete("Model Type") +
  ylab('Soil Moisture [m]') + 
  theme_bw() 
p

filename_figure = "figure_a7_soil_moisture_yearly_avergae_basin"
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = "figure_a7_soil_moisture_yearly_avergae_basin"
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

