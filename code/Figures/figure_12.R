rm(list = ls())
library(tidyverse)
library(scico)

## Prepare outputs for figures
palette_colours = scico(7, palette = "hawaii")
palette_colours[7] = "#222222"
Sys.setlocale("LC_ALL", "en_US.UTF-8")

figure_dir = "out/ssp3/figures/final/"

#### First figure - transpiration sum over basin
transpiration_sum_yearly = read.csv("out/ssp3_preproc/transpiration_plantfate_basin_sum_daily.csv") %>%
  drop_na() %>%
  dplyr::filter(transpiration_plantfate_m != 0) %>% ### Because of set up at first time point transpiration is 0 so we remove it
  mutate(yr = year(time)) %>%
  group_by(yr, afforestation, biodiversity) %>%
  summarise(summed_transpiration = sum(transpiration_plantfate_m))

transpiration_sum_yearly$afforestation[transpiration_sum_yearly$afforestation == 10] <- 1.0
transpiration_sum_yearly$biodiversity[transpiration_sum_yearly$biodiversity == "high"] <- "High"
transpiration_sum_yearly$biodiversity[transpiration_sum_yearly$biodiversity == "low"] <- "Low"
transpiration_sum_yearly$biodiversity <- factor(transpiration_sum_yearly$biodiversity, 
                                    levels = c("High", "Low"))
transpiration_sum_yearly$afforestation <- factor(transpiration_sum_yearly$afforestation, 
                                     levels = c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0),
                                     labels = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"))


p_transpiration_total <- ggplot(transpiration_sum_yearly, aes(x = yr, y = summed_transpiration,
                                                  linetype = biodiversity,
                                                  color = afforestation)) +
  geom_line() +
  ggtitle("Total Forest Yearly Transpiration") +
  scale_color_manual("Afforestation\nLevel", values = palette_colours[1:6], guide = "none") +
  scale_linetype_discrete("Biodiversity", guide = "none") +
  xlab("Year") +
  ylab(bquote('Transpiration [kg'~H[2]~'O'~y^-'1'~']')) +
  theme_bw()
p_transpiration_total

#### Second figure - transpiration average daily per m2

transpiration_average_yearly = read.csv("out/ssp3_preproc/transpiration_forest_average_yearly.csv")

transpiration_average_yearly$afforestation[transpiration_average_yearly$afforestation == "10.0"] <- "1.0"
transpiration_average_yearly$afforestation[transpiration_average_yearly$afforestation == "na"] <- "N/A" 
transpiration_average_yearly$biodiversity[transpiration_average_yearly$biodiversity == "high"] <- "High"
transpiration_average_yearly$biodiversity[transpiration_average_yearly$biodiversity == "low"] <- "Low"
transpiration_average_yearly$biodiversity[transpiration_average_yearly$biodiversity == "na"] <- "Default\nGEB"

transpiration_average_yearly$biodiversity <- factor(transpiration_average_yearly$biodiversity, levels = c("High", "Low", "Default\nGEB"))


p_transpiration_ave <- ggplot(transpiration_average_yearly, aes(x = year, y = transpiration_forest_m, 
                                                linetype = biodiversity,
                                                colour = afforestation)) + 
  geom_line() + 
  ggtitle("Average Annual Forest Transpiration\n(Daily Average)") + 
  scale_color_manual("Afforestation\nLevel", values = palette_colours) +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") + 
  ylab(expression('Transpiration [kg'~H[2]~'O'~d^-1~m^-2~']')) +
  theme_bw()
p_transpiration_ave

#### Combine figure into one

p <- ggpubr::ggarrange(p_transpiration_total, p_transpiration_ave,
                       labels = c("(a)","(b)"),
                       widths = c(3,4))
p  


filename_figure = "forest_transpiration_both"
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = "forest_transpiration_both"
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")
