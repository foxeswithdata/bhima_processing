rm(list = ls())
library(tidyverse)
library(scico)

## Prepare outputs for figures
palette_colours = scico(7, palette = "hawaii")
palette_colours[7] = "#222222"
Sys.setlocale("LC_ALL", "en_US.UTF-8")

figure_dir = "out/ssp3/figures/final/"

#### First figure - average yearly soil moisture
soil_moisture_average_yearly = read.csv("out/ssp3_preproc/soil_moisture_forest_average_yearly.csv")

## Rename values for printing
soil_moisture_average_yearly$afforestation[soil_moisture_average_yearly$afforestation == "10.0"] <- "1.0"
soil_moisture_average_yearly$afforestation[soil_moisture_average_yearly$afforestation == "na"] <- "N/A" 
soil_moisture_average_yearly$biodiversity[soil_moisture_average_yearly$biodiversity == "high"] <- "High"
soil_moisture_average_yearly$biodiversity[soil_moisture_average_yearly$biodiversity == "low"] <- "Low"
soil_moisture_average_yearly$biodiversity[soil_moisture_average_yearly$biodiversity == "na"] <- "Default\nGEB"
soil_moisture_average_yearly$biodiversity <- factor(soil_moisture_average_yearly$biodiversity, levels = c("High", "Low", "Default\nGEB"))

## Plot
p_annual <- ggplot(soil_moisture_average_yearly, aes(x = year, y = soil_moisture, 
                              linetype = biodiversity,
                              colour = afforestation)) + 
  geom_line() + 
  ggtitle("Average Annual Forest \nNormalised Soil Moisture") + 
  scale_color_manual("Afforestation\nLevel", values = palette_colours) +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") + 
  ylab(bquote('Normalized Soil Moisture [m'~m^-1~']')) + 
  theme_bw()
p_annual

### Second figure

soil_moisture_daily_average_2049 = read.csv("out/ssp3_preproc/soil_moisture_forest_rolling_average_14_days.csv") %>%
  drop_na() %>%
  filter(as.Date(time) >= as.Date("01-01-2049", format= "%d-%m-%Y"))

## Rename values for printing

soil_moisture_daily_average_2049$afforestation[soil_moisture_daily_average_2049$afforestation == "10.0"] <- "1.0"
soil_moisture_daily_average_2049$afforestation[soil_moisture_daily_average_2049$afforestation == "na"] <- "N/A" 
soil_moisture_daily_average_2049$biodiversity[soil_moisture_daily_average_2049$biodiversity == "high"] <- "High"
soil_moisture_daily_average_2049$biodiversity[soil_moisture_daily_average_2049$biodiversity == "low"] <- "Low"
soil_moisture_daily_average_2049$biodiversity[soil_moisture_daily_average_2049$biodiversity == "na"] <- "Default\nGEB"
soil_moisture_daily_average_2049$biodiversity <- factor(soil_moisture_daily_average_2049$biodiversity, levels = c("High", "Low", "Default\nGEB"))
soil_moisture_daily_average_2049$afforestation <- as.factor(soil_moisture_daily_average_2049$afforestation)


p_2049 <- ggplot(soil_moisture_daily_average_2049, aes(x = as.Date(time), y = soil_moisture, 
                                 linetype = biodiversity,
                                 color = afforestation)) + 
  geom_line() + 
  ggtitle("Daily Average Forest Normalised Soil Moisture\n(Rolling 14 day Average) ") + 
  scale_color_manual("Afforestation\nLevel", values = palette_colours) +
  scale_linetype_discrete("Biodiversity") +
  xlab("Time") +
  ylab(bquote('Normalized Soil Moisture [m'~m^-1~']')) + 
  theme_bw()
p_2049


#### Combine figures into one plot

p <- ggpubr::ggarrange(p_annual, p_2049, 
                       labels = c("(a)","(b)"),
                       common.legend = TRUE, 
                       legend = "right")
p  

filename_figure = paste("forest_soil_moisture_both")
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("forest_soil_moisture_both")
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")
