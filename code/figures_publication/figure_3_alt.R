rm(list = ls())
library(tidyverse)
library(scico)
## Prepare outputs for figures
palette_colours = scico(7, palette = "hawaii")
palette_colours[7] = "#222222"
Sys.setlocale("LC_ALL", "en_GB.utf8")

figure_dir = "out/figures_publication/"

### Figure for NPP daily in 2049 total for plantfate forest

NPP_daily_total_2049 = read.csv("out/ssp3/spatial_preprocessing/NPP/NPP_plantfate_basin_sum_daily_rolling.csv") %>%
  drop_na() %>%
  filter(as.Date(time) >= as.Date("01-01-2049", format= "%d-%m-%Y"))


NPP_daily_total_2049$afforestation[NPP_daily_total_2049$afforestation == 10] <- 1.0
NPP_daily_total_2049$biodiversity[NPP_daily_total_2049$biodiversity == "high"] <- "High"
NPP_daily_total_2049$biodiversity[NPP_daily_total_2049$biodiversity == "low"] <- "Low"
NPP_daily_total_2049$biodiversity <- factor(NPP_daily_total_2049$biodiversity, 
                                                levels = c("High", "Low"))
NPP_daily_total_2049$afforestation <- factor(NPP_daily_total_2049$afforestation, 
                                                 levels = c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0),
                                                 labels = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"))

p_NPP_total <- ggplot(NPP_daily_total_2049, aes(x = as.Date(time), y = NPP_forest_plantFATE,
                                      linetype = biodiversity,
                                      color = afforestation)) +
  geom_line() +
  ggtitle(paste0("Total Basin Daily Forest \nNet Primary Productivity\n(Rolling 14-day Average)",  sep = "")) +
  scale_color_manual("Afforestation\nLevel", values = palette_colours[1:6]) +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") + 
  ylab(bquote('Net Primary Productivity [kgC'~d^-1~']')) + 
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.title=element_text(size=8),
        legend.text = element_text(size=8))
p_NPP_total

### NPP average forest NPP 

NPP_daily_ave_2049 = read.csv("out/ssp3/spatial_preprocessing/NPP/NPP_plantfate_rolling_average_14_days.csv") %>%
  drop_na() %>%
  filter(as.Date(time) >= as.Date("01-01-2049", format= "%d-%m-%Y"))

NPP_daily_ave_2049$afforestation[NPP_daily_ave_2049$afforestation == 10] <- 1.0
NPP_daily_ave_2049$biodiversity[NPP_daily_ave_2049$biodiversity == "high"] <- "High"
NPP_daily_ave_2049$biodiversity[NPP_daily_ave_2049$biodiversity == "low"] <- "Low"
NPP_daily_ave_2049$biodiversity <- factor(NPP_daily_ave_2049$biodiversity, 
                                      levels = c("High", "Low"))
NPP_daily_ave_2049$afforestation <- factor(NPP_daily_ave_2049$afforestation, 
                                       levels = c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0),
                                       labels = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"))

p_NPP_average <- ggplot(NPP_daily_ave_2049, aes(x = as.Date(time), y = NPP,
                                          linetype = biodiversity,
                                          color = afforestation)) +
  geom_line() +
  ggtitle(paste0("Average Basin Daily Forest \nNet Primary Productivity\n(Rolling 14-day Average)",  sep = "")) +
  scale_color_manual("Afforestation\nLevel", values = palette_colours[1:6]) +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") + 
  ylab(bquote('Net Primary Productivity [kgC' * d^-1 * m^-1 * ']')) + 
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.title=element_text(size=8),
        legend.text = element_text(size=8))
p_NPP_average


p <- ggpubr::ggarrange(p_NPP_total, p_NPP_average, 
                       labels = c("(a)","(b)"),
                       common.legend = TRUE, 
                       legend = "right")
p  



filename_figure = paste("figure_3_alt", "NPP", "rolling_14_day", "sum", 'and', 'average', "plantfate", "2049", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("figure_3_alt", "NPP", "rolling_14_day", "sum", 'and', 'average', "plantfate", "2049", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = "png", path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

