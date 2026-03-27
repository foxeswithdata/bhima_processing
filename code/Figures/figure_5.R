rm(list = ls())
library(tidyverse)
library(scico)

## Prepare outputs for figures
palette_colours = scico(7, palette = "hawaii")
palette_colours[7] = "#222222"
Sys.setlocale("LC_ALL", "en_GB.utf8-8")

figure_dir = "out/ssp3/figures/final/"


parameters <- c("biomass", "transpiration", "NPP")

data <- data.frame(filename = parameters,
                   name = c("Biomass", "Transpiration", "Net Primary Productivity"),
                   yaxis = c("Biomass kgC", "Transpiration kgH20", "Net Primary Productivity kgC"))

NPP_daily_2049 = read.csv("out/ssp3_preproc/NPP_plantfate_basin_sum_daily_rolling.csv") %>%
  drop_na() %>%
  filter(as.Date(time) >= as.Date("01-01-2049", format= "%d-%m-%Y"))


NPP_daily_2049$afforestation[NPP_daily_2049$afforestation == 10] <- 1.0
NPP_daily_2049$biodiversity[NPP_daily_2049$biodiversity == "high"] <- "High"
NPP_daily_2049$biodiversity[NPP_daily_2049$biodiversity == "low"] <- "Low"
NPP_daily_2049$biodiversity <- factor(NPP_daily_2049$biodiversity, 
                                                levels = c("High", "Low"))
NPP_daily_2049$afforestation <- factor(NPP_daily_2049$afforestation, 
                                                 levels = c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0),
                                                 labels = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"))

p <- ggplot(NPP_daily_2049, aes(x = as.Date(time), y = NPP_forest_plantFATE,
                                      linetype = biodiversity,
                                      color = afforestation)) +
  geom_line() +
  ggtitle(paste0("Total Basin Daily Forest Net Primary Productivity\n(Rolling 14-day Average)",  sep = "")) +
  scale_color_manual("Afforestation\nLevel", values = palette_colours[1:6]) +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") + 
  ylab(bquote('Net Primary Productivity [kgC'~d^-1~']')) + 
  theme_bw()
p

filename_figure = paste("NPP", "rolling_14_day", "sum", "plantfate", "2049", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("NPP", "rolling_14_day", "sum", "plantfate", "2049", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = "png", path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

