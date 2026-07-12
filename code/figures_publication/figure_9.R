rm(list = ls())
library(tidyverse)
library(scico)

## Prepare outputs for figures
palette_colours = scico(7, palette = "hawaii")
palette_colours[7] = "#222222"
Sys.setlocale("LC_ALL", "en_US.UTF-8")

figure_dir = "out/figures_publication//"
dir.create(figure_dir, showWarnings = FALSE, recursive = TRUE)

## First figure NPP
### NPP
NPP_plantFATE_yearly = read.csv("out/ssp3/spatial_preprocessing/NPP/NPP_plantfate_basin_sum_yearly.csv")

NPP_plantFATE_yearly$afforestation[NPP_plantFATE_yearly$afforestation == 10] <- 1.0
NPP_plantFATE_yearly$biodiversity[NPP_plantFATE_yearly$biodiversity == "high"] <- "High"
NPP_plantFATE_yearly$biodiversity[NPP_plantFATE_yearly$biodiversity == "low"] <- "Low"
NPP_plantFATE_yearly$biodiversity <- factor(NPP_plantFATE_yearly$biodiversity, 
                                    levels = c("High", "Low"))
NPP_plantFATE_yearly$afforestation <- factor(NPP_plantFATE_yearly$afforestation, 
                                     levels = c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0),
                                     labels = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"))

p_NPP_total <- ggplot(NPP_plantFATE_yearly, aes(x = year, y = NPP_forest_plantFATE,
                                        linetype = biodiversity,
                                        color = afforestation)) +
  geom_line() +
  ggtitle("Total Forest Yearly \nNet Primary Productivity") +
  scale_color_manual("Afforestation\nLevel", values = palette_colours[1:6]) +
  xlab("Year") +
  ylab(bquote('NPP [kgC'~y^-'1'~']')) +
  scale_linetype_discrete("Biodiversity") +
  theme_bw()
p_NPP_total


### Biomass
biomass_plantFATE_yearly = read.csv("out/ssp3/spatial_preprocessing/biomass/biomass_plantfate_basin_sum_yearly.csv")
  
biomass_plantFATE_yearly$afforestation[biomass_plantFATE_yearly$afforestation == 10] <- 1.0
biomass_plantFATE_yearly$biodiversity[biomass_plantFATE_yearly$biodiversity == "high"] <- "High"
biomass_plantFATE_yearly$biodiversity[biomass_plantFATE_yearly$biodiversity == "low"] <- "Low"
biomass_plantFATE_yearly$biodiversity <- factor(biomass_plantFATE_yearly$biodiversity, 
                                    levels = c("High", "Low"))
biomass_plantFATE_yearly$afforestation <- factor(biomass_plantFATE_yearly$afforestation, 
                                     levels = c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0),
                                     labels = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"))

p_biomass_total <- ggplot(biomass_plantFATE_yearly, aes(x = year, y = biomass_forest_plantFATE,
                                            linetype = biodiversity,
                                            color = afforestation)) +
  geom_line() +
  ggtitle("Total Forest Yearly Biomass") +
  scale_color_manual("Afforestation\nLevel", values = palette_colours[1:6]) +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") +
  ylab("Biomass [kgC]") +
  theme_bw()
p_biomass_total

p <- ggpubr::ggarrange(p_NPP_total, p_biomass_total,
                       labels = c("(a)","(b)"),
                       common.legend = TRUE, 
                       legend = "right")
p  

filename_figure = paste("figure_9_forest_npp_biodiversity_both")
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("figure_9_forest_npp_biodiversity_both")
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")


addedvals = c(0, diff(biomass_plantFATE_yearly$biomass_forest_plantFATE[biomass_plantFATE_yearly$afforestation == "1.0" & biomass_plantFATE_yearly$biodiversity == "High"]))
biomass_plantFATE_yearly$biomass_forest_plantFATE[biomass_plantFATE_yearly$afforestation == "1.0" & biomass_plantFATE_yearly$biodiversity == "High"]

plot(diff(biomass_plantFATE_yearly$biomass_forest_plantFATE[biomass_plantFATE_yearly$afforestation == "1.0" & biomass_plantFATE_yearly$biodiversity == "High"]), type = "b")
