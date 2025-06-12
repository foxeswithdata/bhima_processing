# script to plot the output from GEB
# first section: plot stats by time files (csvs created from original zarr files using load_zarr.py)
# second section: plot weighted means files (csvs created directly from GEB)
# 12.06.25

# setwd("C:/Users/maxwell/OneDrive - University of Cambridge/Documents/09_IIASA/04_Work/bhima_processing")

library(tidyverse)
library(ggpubr) #ggarrange

#weighted means files (direct output from GEB run) - Note: need to check whether this is all cells or just forest cells
soil_moisture <- read.csv("data/spinup/test/soil_moisture_weighted_mean_m.csv")
transpiration <- read.csv("data/spinup/test/transpiration_weighted_mean_m.csv")
evaporation <- read.csv("data/spinup/test/soil_evaporation_weighted_mean_m.csv")

#stats by time (outputs of the file load_zarr.py)
soil_moisture_forest_long <- read.csv("data/spinup/test/processed/soil_moisture_stats_by_time.csv")
transpiration_forest_long <- read.csv("data/spinup/test/processed/transpiration_stats_by_time.csv")


soil_moisture_forest <- soil_moisture_forest_long %>% 
  pivot_wider(names_from = level_1, values_from = soil_moisture_forest_m)

transpiration_forest <- transpiration_forest_long %>% 
  pivot_wider(names_from = level_1, values_from = transpiration_forest_m)


################## From stats by time files (csvs created from original zarr files using load_zarr.py) ############

p<- ggplot(soil_moisture_forest)+
  # geom_ribbon(aes(x = time, ymin = ci_lower, ymax = ci_upper),
  #             fill = "green") +
  # geom_line(aes(x = time, y = ci_lower),
  #             color = "green") +
  # geom_line(aes(x = time, y = ci_upper),
  #           color = "green") +
  # geom_errorbar(aes(x = time, ymin = mean - std, ymax = mean + std), width = 0.1)+
  geom_point(aes(x = time, y = mean), size = 0.8)+
  theme_bw()+
  labs(x = "Time", y = "Soil moisture in forests (mean)")



q<- ggplot(transpiration_forest)+
  # geom_ribbon(aes(x = time, ymin = ci_lower, ymax = ci_upper),
  #             fill = "green") +
  # geom_line(aes(x = time, y = ci_lower),
  #             color = "green") +
  # geom_line(aes(x = time, y = ci_upper),
  #           color = "green") +
  # geom_errorbar(aes(x = time, ymin = mean - std, ymax = mean + std), width = 0.1)+
  geom_point(aes(x = time, y = mean), size = 0.8)+
  theme_bw()+
  labs(x = "Time", y = "Transpiration in forests (mean)")

soilmoisture_transpiration <- ggarrange(p, q,
                                     ncol = 1, nrow = 2)
soilmoisture_transpiration

# ggsave("data/spinup/test/plots/soilmoisture_transpiration_forests_from_zarr.png",soilmoisture_transpiration,
#        width = 15.36, height = 8.14)

################## From weighted means files (direct output from GEB) ############


p<- ggplot(soil_moisture, aes(x = date, y = soil_moisture_weighted_mean_m))+
  geom_point()+
  theme_bw()

p

## looking more closely at certain time
p<- transpiration %>% 
  mutate(Year = year(date),
         Month = month(date)) %>% 
  # filter(Year %in% (1975:1976)) %>%
  ggplot(aes(x = date, y = transpiration_weighted_mean_m))+
  geom_point()+
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
p

summary<- transpiration %>% 
  mutate(Year = year(date),
         Month = month(date)) %>% 
  group_by(Year, Month) %>% 
  summarise(mean = mean(transpiration_weighted_mean_m)) %>%  
  # arrange(match(year.name,Year), match(month.name, Month)) %>% 
  mutate(year_month = paste(Year, Month, sep = "_")) %>% 
  mutate(year_month = as.factor(year_month)) %>% 
  ungroup() %>% 
  mutate(ID = row_number()) 

  
p<- ggplot(summary, aes(x = ID, y = mean))+
  geom_line()+
  theme_bw() + 
  # scale_x_continuous(labels = year_month)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

p

p<- evaporation %>% 
  mutate(Year = year(date),
         Month = month(date)) %>% 
  filter(Year %in% (1975:1976)) %>%
  ggplot(aes(x = date, y = soil_evaporation_weighted_mean_m))+
  geom_point()+
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
p
