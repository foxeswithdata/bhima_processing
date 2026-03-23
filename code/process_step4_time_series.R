rm(list = ls())
library(tidyverse)
library(ggpubr)

## Read in file

list.files("out/ssp3_preproc/")

parameters <- c("soil_moisture", "transpiration", "groundwater_recharge")

data <- data.frame(filename = parameters,
                   name = c("Normalized Soil Moisture", "Transpiration (Daily Average)", "Groundwater Recharge"),
                   yaxis = c("Normalized Soil Moisture [m/m]", "Transpiration (kgH20/m2)", "Groundwater Recharge (m)"))

figure_dir = "out/ssp3/figures"

one_to_one_plots = c()

### Forest averages

for (n in 1:nrow(data)){
  
  #Process yearly data
  
  param_yearly = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_yearly.csv", sep = ""))
  param_yearly$afforestation[param_yearly$afforestation == "10.0"] <- "1.0"
  colnames(param_yearly)[2] <- "var"
  
  p <- ggplot(param_yearly, aes(x = year, y = var, 
                                        linetype = biodiversity,
                                        colour = afforestation)) + 
    geom_line() + 
    facet_wrap(~afforestation, ncol = 2) + 
    ggtitle(paste0("Average Annual Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename[n], "annual", "average", "forest", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  p <- ggplot(param_yearly, aes(x = year, y = var, 
                                linetype = biodiversity,
                                colour = afforestation)) + 
    geom_line() + 
    ggtitle(paste0("Average Annual Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  # filename_figure = paste(data$filename[n], "annual", "average", "forest", sep = "_")
  # filename_figure = paste(filename_figure, "png", sep = ".")
  # filename_figure = file.path(figure_dir, filename_figure)
  # ggsave(filename_figure, plot = p, device = NULL, path = NULL,
  #        scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
  #        units =  "mm")
  # 
  # param_yearly_one_to_one_hb <- param_yearly %>%
  #   filter(biodiversity %in% c("na", "high") & afforestation %in% c("0.0", "na")) %>%
  #   select(-one_of(c("spatial_ref", "crs", "afforestation"))) %>%
  #   pivot_wider(values_from = var, names_from = biodiversity) %>%
  #   mutate(biodiversity = "high")
  # 
  # param_yearly_one_to_one_lb <- param_yearly %>%
  #   filter(biodiversity %in% c("na", "low") & afforestation %in% c("0.0", "na")) %>%
  #   select(-one_of(c("spatial_ref", "crs", "afforestation"))) %>%
  #   pivot_wider(values_from = var, names_from = biodiversity) %>%
  #   mutate(biodiversity = "low")
  # 
  # colnames(param_yearly_one_to_one_hb)[colnames(param_yearly_one_to_one_hb) == "na"] <- "GEB"
  # colnames(param_yearly_one_to_one_hb)[colnames(param_yearly_one_to_one_hb) == "high"] <- "PlantFATE"
  # colnames(param_yearly_one_to_one_lb)[colnames(param_yearly_one_to_one_lb) == "na"] <- "GEB"
  # colnames(param_yearly_one_to_one_lb)[colnames(param_yearly_one_to_one_lb) == "low"] <- "PlantFATE"
  # 
  # param_yearly_one_to_one <- rbind(param_yearly_one_to_one_hb, param_yearly_one_to_one_lb)
  # one_to_one_line <- data.frame(x = c(min(param_yearly_one_to_one$GEB), max(param_yearly_one_to_one$GEB)),
  #                               y = c(min(param_yearly_one_to_one$PlantFATE), max(param_yearly_one_to_one$PlantFATE)))
  # 
  # p <- ggplot(param_yearly_one_to_one, aes(x = GEB, y = PlantFATE)) + 
  #   geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed", alpha = 0.75) + 
  #   geom_point(alpha = 0.7) +
  #   facet_wrap(~biodiversity) + 
  #   ggtitle(paste0("1-to-1 line yearly Forest ", data$name[n],  sep = ""))
  # p
  # 
  # filename_figure = paste(data$filename[n], "annual", "one_to_one", "forest", sep = "_")
  # filename_figure = paste(filename_figure, "png", sep = ".")
  # filename_figure = file.path(figure_dir, filename_figure)
  # ggsave(filename_figure, plot = p, device = NULL, path = NULL,
  #        scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
  #        units =  "mm")
    
  #Process monthly data
  param_monthly = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_monthly.csv", sep = "")) 
  param_monthly$afforestation[param_monthly$afforestation == "10.0"] <- "1.0"
  param_monthly <- param_monthly %>%
    mutate(my_date = paste(15, month, year, sep = '-')) %>% 
    mutate(my_date = as.Date(my_date, format = '%d-%m-%Y', origin = '1970-01-01'))
  colnames(param_monthly)[3] <- "var"
  
  p <- ggplot(param_monthly, aes(x = my_date, y = var, 
                                linetype = biodiversity,
                                color = afforestation)) + 
    geom_line() + 
    facet_wrap(~afforestation, ncol = 2) + 
    ggtitle(paste0("Average Monthly Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename[n], "monthly", "average", "forest", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  p <- ggplot(param_monthly, aes(x = my_date, y = var, 
                                 linetype = biodiversity,
                                 color = afforestation)) + 
    geom_line() + 
    ggtitle(paste0("Average Monthly Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename[n], "monthly", "average", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  param_monthly_sub <- param_monthly %>%
    filter(my_date >= as.Date("01-01-2049", format= "%d-%m-%Y"))
  
  p <- ggplot(param_monthly_sub, aes(x = my_date, y = var, 
                                 linetype = biodiversity,
                                 color = afforestation)) + 
    geom_line() + 
    ggtitle(paste0("Average Monthly Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename[n], "monthly", "average", "forest", "2049", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  # param_monthly_one_to_one_hb <- param_monthly %>%
  #   filter(biodiversity %in% c("na", "high") & afforestation %in% c("0.0", "na")) %>%
  #   select(-one_of(c("spatial_ref", "crs", "afforestation"))) %>%
  #   pivot_wider(values_from = var, names_from = biodiversity) %>%
  #   mutate(biodiversity = "high")
  # 
  # param_monthly_one_to_one_lb <- param_monthly %>%
  #   filter(biodiversity %in% c("na", "low") & afforestation %in% c("0.0", "na")) %>%
  #   select(-one_of(c("spatial_ref", "crs", "afforestation"))) %>%
  #   pivot_wider(values_from = var, names_from = biodiversity) %>%
  #   mutate(biodiversity = "low")
  # 
  # colnames(param_monthly_one_to_one_hb)[colnames(param_monthly_one_to_one_hb) == "na"] <- "GEB"
  # colnames(param_monthly_one_to_one_hb)[colnames(param_monthly_one_to_one_hb) == "high"] <- "PlantFATE"
  # colnames(param_monthly_one_to_one_lb)[colnames(param_monthly_one_to_one_lb) == "na"] <- "GEB"
  # colnames(param_monthly_one_to_one_lb)[colnames(param_monthly_one_to_one_lb) == "low"] <- "PlantFATE"
  # 
  # 
  # param_monthly_one_to_one <- rbind(param_monthly_one_to_one_hb, param_monthly_one_to_one_lb)
  # one_to_one_line <- data.frame(x = c(min(param_monthly_one_to_one$GEB), max(param_monthly_one_to_one$GEB)),
  #                               y = c(min(param_monthly_one_to_one$PlantFATE), max(param_monthly_one_to_one$PlantFATE)))
  # 
  # p <- ggplot(param_monthly_one_to_one, aes(x = GEB, y = PlantFATE)) + 
  #   geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed", alpha = 0.75) + 
  #   geom_point(alpha = 0.5) +
  #   facet_wrap(~biodiversity) + 
  #   ggtitle(paste0("1-to-1 line monthly Forest ", data$name[n],  sep = ""))
  # p
  # 
  # filename_figure = paste(data$filename[n], "monthly", "one_to_one", "forest", sep = "_")
  # filename_figure = paste(filename_figure, "png", sep = ".")
  # filename_figure = file.path(figure_dir, filename_figure)
  # ggsave(filename_figure, plot = p, device = NULL, path = NULL,
  #        scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
  #        units =  "mm")
  # 
  #Process rolling average data
  param_roll_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_rolling_average_14_days.csv", sep = ""))
  param_roll_daily$afforestation[param_roll_daily$afforestation == "10.0"] <- "1.0"
  param_roll_daily <- param_roll_daily %>%
    drop_na() 
  colnames(param_roll_daily)[2] <- "var"
  
  p <- ggplot(param_roll_daily, aes(x = as.Date(time), y = var, 
                                    linetype = biodiversity,
                                    color = afforestation)) + 
    geom_line() + 
    ggtitle(paste0("Daily Rolling Average (14 days) Forest ", data$name[n],  sep = "")) + 
    xlab("Time") + 
    ylab(data$yaxis[n])
  p
  
  
  filename_figure = paste(data$filename[n], "rolling_14_day", "average", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  p <- ggplot(param_roll_daily, aes(x = as.Date(time), y = var, 
                                 linetype = biodiversity,
                                 color = afforestation)) + 
    geom_line() + 
    facet_wrap(~afforestation, ncol = 2) + 
    ggtitle(paste0("Daily Rolling Average (14 days) Forest ", data$name[n],  sep = "")) + 
    xlab("Time") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename[n], "rolling_14_day", "average", "forest", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  param_daily_sub <- param_roll_daily %>%
    filter(as.Date(time) >= as.Date("01-01-2049", format= "%d-%m-%Y"))
  
  
  param_daily_sub$afforestation[param_daily_sub$afforestation == "na"] <- "N/A" 
  param_daily_sub$biodiversity[param_daily_sub$biodiversity == "high"] <- "High"
  param_daily_sub$biodiversity[param_daily_sub$biodiversity == "low"] <- "Low"
  param_daily_sub$biodiversity[param_daily_sub$biodiversity == "na"] <- "Default\nGEB"
  
  param_daily_sub$biodiversity <- factor(param_daily_sub$biodiversity, levels = c("High", "Low", "Default\nGEB"))
  param_daily_sub$afforestation <- as.factor(param_daily_sub$afforestation)
  
  
  p <- ggplot(param_daily_sub, aes(x = as.Date(time), y = var, 
                                     linetype = biodiversity,
                                     color = afforestation)) + 
    geom_line() + 
    ggtitle(paste0("Daily Average Forest ", data$name[n], "\n (Rolling 14 day Average) ",  sep = "")) + 
    scale_color_discrete("Afforestation\nLevel") +
    xlab("Year") +
    scale_linetype_discrete("Biodiversity") +
    ylab(data$yaxis[n]) +
    theme_bw()
  p
  
  
  filename_figure = paste(data$filename[n], "rolling_14_day", "average", "forest", "2049", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  filename_figure = paste(data$filename[n], "rolling_14_day", "average", "forest", "2049", sep = "_")
  filename_figure = paste(filename_figure, "eps", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  #Process average daily data
  param_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_daily.csv", sep = ""))
  param_daily <- param_daily %>%
    select(-c("spatial_ref", "crs"))
  colnames(param_daily)[2] <- "var"
  
  param_daily_one_to_one <- param_daily %>%
    filter(biodiversity %in% c("na", "high") & afforestation %in% c("0.0", "na")) %>%
    select(-"afforestation") %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "high") 
  
  # param_daily_one_to_one_lb <- param_daily %>%
  #   filter(biodiversity %in% c("na", "low") & afforestation %in% c("0.0", "na")) %>%
  #   select(-one_of(c("afforestation"))) %>%
  #   pivot_wider(values_from = var, names_from = biodiversity) %>%
  #   mutate(biodiversity = "low") 
  
  colnames(param_daily_one_to_one)[colnames(param_daily_one_to_one) == "na"] <- "GEB"
  colnames(param_daily_one_to_one)[colnames(param_daily_one_to_one) == "high"] <- "PlantFATE"
  # colnames(param_daily_one_to_one_lb)[colnames(param_daily_one_to_one_lb) == "na"] <- "GEB"
  # colnames(param_daily_one_to_one_lb)[colnames(param_daily_one_to_one_lb) == "low"] <- "PlantFATE"
  
  
  one_to_one_line <- data.frame(x = c(min(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE)), 
                                      max(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE))), 
                                y = c(min(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE)), 
                                      max(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE))))
  
  p <- ggplot(param_daily_one_to_one, aes(x = PlantFATE, y = GEB)) + 
    geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed") + 
    geom_point(alpha = 0.05) +
    ggtitle(paste0("1-to-1 line Daily Average Forest ", data$name[n],  sep = ""))
  p
  
  one_to_one_plots = c(one_to_one_plots, p)
  
  filename_figure = paste(data$filename[n], "daily", "one_to_one", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  
  #Process monsoon season data
  
  param_monsoon = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_monsoon.csv", sep = "")) %>%
    drop_na()
  param_monsoon$afforestation[param_monsoon$afforestation == "10.0"] <- "1.0"
  colnames(param_monsoon)[2] <- "var"
  
  p <- ggplot(param_monsoon, aes(x = year, y = var, 
                                 linetype = biodiversity,
                                 color = afforestation)) + 
    geom_line() + 
    ggtitle(paste0("Average Annual Monsoon Season Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  
  filename_figure = paste(data$filename[n], "monsoon", "average", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  p <- ggplot(param_monsoon, aes(x = year, y = var, 
                                linetype = biodiversity,
                                color = afforestation)) + 
    geom_line() + 
    facet_wrap(~afforestation, ncol = 2) + 
    ggtitle(paste0("Average Annual Monsoon Season Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename[n], "monsoon", "average", "forest", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  #Process dry season data
  
  param_dry = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_dry_season.csv", sep = "")) %>%
    drop_na()
  param_dry$afforestation[param_dry$afforestation == "10.0"] <- "1.0"
  colnames(param_dry)[2] <- "var"
  
  p <- ggplot(param_dry, aes(x = year, y = var, 
                                linetype = biodiversity,
                             color = afforestation)) + 
    geom_line() + 
    ggtitle(paste0("Average Annual Dry Season Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename[n], "dry_season", "average", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  p <- ggplot(param_dry, aes(x = year, y = var, 
                             linetype = biodiversity,
                             color = afforestation)) + 
    geom_line() + 
    facet_wrap(~afforestation, ncol = 2) + 
    ggtitle(paste0("Average Annual Dry Season Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename[n], "dry_season", "average", "forest", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
}



### Combine one-to-one plots

n = 1
param_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_daily.csv", sep = ""))
param_daily <- param_daily
colnames(param_daily)[2] <- "var"

param_daily_one_to_one <- param_daily %>%
  filter(biodiversity %in% c("na", "high") & afforestation %in% c("0.0", "na")) %>%
  select(-"afforestation") %>%
  pivot_wider(values_from = var, names_from = biodiversity) %>%
  mutate(biodiversity = "high") 

colnames(param_daily_one_to_one)[colnames(param_daily_one_to_one) == "na"] <- "GEB"
colnames(param_daily_one_to_one)[colnames(param_daily_one_to_one) == "high"] <- "PlantFATE"

one_to_one_line <- data.frame(x = c(min(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE)), 
                                    max(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE))), 
                              y = c(min(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE)), 
                                    max(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE))))

p_moisture <- ggplot(param_daily_one_to_one, aes(x = PlantFATE, y = GEB)) + 
  geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed") + 
  geom_point(alpha = 0.05) +
  ggtitle("Average Normalized Soil Moisture [m/m]")+
  scale_x_continuous("GEB-PlantFATE") +
  theme_bw()
p_moisture

n = 2
param_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_daily.csv", sep = ""))
param_daily <- param_daily %>%
  select(-c("spatial_ref", "crs"))
colnames(param_daily)[2] <- "var"

param_daily_one_to_one <- param_daily %>%
  filter(biodiversity %in% c("na", "high") & afforestation %in% c("0.0", "na")) %>%
  select(-"afforestation") %>%
  pivot_wider(values_from = var, names_from = biodiversity) %>%
  mutate(biodiversity = "high") 

colnames(param_daily_one_to_one)[colnames(param_daily_one_to_one) == "na"] <- "GEB"
colnames(param_daily_one_to_one)[colnames(param_daily_one_to_one) == "high"] <- "PlantFATE"

one_to_one_line <- data.frame(x = c(min(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE)), 
                                    max(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE))), 
                              y = c(min(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE)), 
                                    max(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE))))

p_transpiration <- ggplot(param_daily_one_to_one, aes(x = PlantFATE, y = GEB)) + 
  geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed") + 
  geom_point(alpha = 0.05) +
  ggtitle("Average Transpiration [kgH20/m2])")+
  scale_x_continuous("GEB-PlantFATE") +
  theme_bw()
p_transpiration


n = 3
param_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_daily.csv", sep = ""))
param_daily <- param_daily %>%
  select(-c("spatial_ref", "crs"))
colnames(param_daily)[2] <- "var"

param_daily_one_to_one <- param_daily %>%
  filter(biodiversity %in% c("na", "high") & afforestation %in% c("0.0", "na")) %>%
  select(-"afforestation") %>%
  pivot_wider(values_from = var, names_from = biodiversity) %>%
  mutate(biodiversity = "high") 

colnames(param_daily_one_to_one)[colnames(param_daily_one_to_one) == "na"] <- "GEB"
colnames(param_daily_one_to_one)[colnames(param_daily_one_to_one) == "high"] <- "PlantFATE"

one_to_one_line <- data.frame(x = c(min(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE)), 
                                    max(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE))), 
                              y = c(min(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE)), 
                                    max(c(param_daily_one_to_one$GEB, param_daily_one_to_one$PlantFATE))))

p_groundwater <- ggplot(param_daily_one_to_one, aes(x = PlantFATE, y = GEB)) + 
  geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed") + 
  geom_point(alpha = 0.05) +
  ggtitle("Average Groundwater Recharge [m]")+
  scale_x_continuous("GEB-PlantFATE") +
  theme_bw()
p_groundwater




all_plots <- ggarrange(p_moisture, p_groundwater, p_transpiration,
          labels = c("(a)", "(b)", "(c)"),
          ncol = 3, nrow = 1)
all_plots

filename_figure = paste("all", "daily", "basinwide", "one_to_one", "forest", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = all_plots, device = NULL, path = NULL,
       scale = 1, width = 400, height = 140, dpi = 350, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("all", "daily", "basinwide", "one_to_one", "forest", sep = "_")
filename_figure = paste(filename_figure, "tiff", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = all_plots, device = NULL, path = NULL,
       scale = 1, width = 400, height = 140, dpi = 350, limitsize = TRUE,
       units =  "mm")



### PlantFATE sums

parameters <- c("biomass", "transpiration", "NPP")

data <- data.frame(filename = parameters,
                   name = c("Biomass", "Transpiration", "Net Primary Productivity"),
                   yaxis = c("Biomass kgC", "Transpiration kgH20", "Net Primary Productivity kgC"))

for (n in 1:nrow(data)){

  #Process daily data
  param_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_plantfate_basin_sum_daily.csv", sep = "")) %>%
    drop_na()
  param_daily$afforestation[param_daily$afforestation == 10] <- 1.0
  param_daily <- param_daily %>%
    select(-c("spatial_ref", "crs"))
  colnames(param_daily)[2] <- "var"
  param_daily <- param_daily %>%
    dplyr::filter(var != 0)

  yaxis = paste(data$yaxis[n], "per day")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }

  p <- ggplot(param_daily, aes(x = as.Date(time), y = var,
                                linetype = biodiversity,
                               color = as.factor(afforestation))) +
    geom_line() +
    facet_wrap(~afforestation, ncol = 2) +
    ggtitle(paste0("Total Forest Daily ", data$name[n],  sep = "")) +
    xlab("Time") +
    ylab(yaxis)
  p

  filename_figure = paste(data$filename[n],"daily", "sum", "plantfate", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  p <- ggplot(param_daily, aes(x = as.Date(time), y = var,
                                linetype = biodiversity,
                                colour = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Total Forest Daily ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(yaxis)
  p

  filename_figure = paste(data$filename[n],"daily", "sum", "plantfate", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  param_daily_sub <- param_daily %>%
    filter(as.Date(time) >= as.Date("01-01-2049", format= "%d-%m-%Y"))

  p <- ggplot(param_daily_sub, aes(x = as.Date(time), y = var,
                                   linetype = biodiversity,
                                   color = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Total Forest Daily ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(data$yaxis[n])
  p

  filename_figure = paste(data$filename[n], "daily", "sum", "plantfate", "2049", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  ### Monthly

  param_monthly <- param_daily %>%
    mutate(yr = year(time),
           mnth = month(time)) %>%
    group_by(yr, mnth, afforestation, biodiversity) %>%
    summarise(summed = sum(var)) %>%
    mutate(time = as.Date(paste(15, mnth, yr, sep = "-"), format = "%d-%m-%Y"))

  yaxis = paste(data$yaxis[n], "per month")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }

  p <- ggplot(param_monthly, aes(x = time, y = summed,
                               linetype = biodiversity,
                               color = as.factor(afforestation))) +
    geom_line() +
    facet_wrap(~afforestation, ncol = 2) +
    ggtitle(paste0("Total Forest Monthly ", data$name[n],  sep = "")) +
    xlab("Time") +
    ylab(yaxis)
  p



  filename_figure = paste(data$filename[n], "monthly", "sum", "plantfate","facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  p <- ggplot(param_monthly, aes(x = as.Date(time), y = summed,
                               linetype = biodiversity,
                               colour = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Total Forest Monthly ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(yaxis)
  p

  filename_figure = paste(data$filename[n], "monthly", "sum", "plantfate", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")


  param_monthly_sub <- param_monthly %>%
    filter(as.Date(time) >= as.Date("01-01-2049", format= "%d-%m-%Y"))

  p <- ggplot(param_monthly_sub, aes(x = as.Date(time), y = summed,
                                   linetype = biodiversity,
                                   color = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Total Forest Monthly ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(data$yaxis[n])
  p

  filename_figure = paste(data$filename[n], "monthly", "sum", "plantfate", "2049", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  ### Yearly

  param_yearly <- param_daily %>%
    mutate(yr = year(time)) %>%
    group_by(yr, afforestation, biodiversity) %>%
    summarise(summed = sum(var))

  yaxis = paste(data$yaxis[n], "per month")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }

  p <- ggplot(param_yearly, aes(x = yr, y = summed,
                                 linetype = biodiversity,
                                 color = as.factor(afforestation))) +
    geom_line() +
    facet_wrap(~afforestation, ncol = 2) +
    ggtitle(paste0("Total Forest Yearly ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(yaxis)
  p


  filename_figure = paste(data$filename[n], "yearly", "sum", "plantfate", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  p <- ggplot(param_yearly, aes(x = yr, y = summed,
                               linetype = biodiversity,
                               colour = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Total Forest Yearly ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(yaxis)
  p


  filename_figure = paste(data$filename[n], "yearly", "sum", "plantfate", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  #Process rolling average data
  param_roll_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_plantfate_basin_sum_daily_rolling.csv", sep = "")) %>%
    drop_na()
  param_roll_daily$afforestation[param_roll_daily$afforestation == 10] <- 1.0
  param_roll_daily <- param_roll_daily
  colnames(param_roll_daily)[2] <- "var"

  yaxis = paste(data$yaxis[n], "/d")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }

  p <- ggplot(param_roll_daily, aes(x = as.Date(time), y = var,
                                    linetype = biodiversity,
                                    color = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Daily (Rolling 14 day Average) Forest ", data$name[n],  sep = "")) +
    xlab("Time") +
    ylab(yaxis)
  p

  filename_figure = paste(data$filename[n], "rolling_14_day", "sum", "plantfate", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  p <- ggplot(param_roll_daily, aes(x = as.Date(time), y = var,
                                    linetype = biodiversity,
                                    color = as.factor(afforestation))) +
    geom_line() +
    facet_wrap(~afforestation, ncol = 2) +
    ggtitle(paste0("Daily (Rolling 14 day Average) Forest ", data$name[n],  sep = "")) +
    xlab("Time") +
    ylab(yaxis)
  p

  filename_figure = paste(data$filename[n], "rolling_14_day", "sum", "plantfate", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")


  param_roll_daily_sub <- param_roll_daily %>%
    filter(as.Date(time) >= as.Date("01-01-2049", format= "%d-%m-%Y"))

  param_roll_daily_sub$biodiversity[param_roll_daily_sub$biodiversity == "high"] <- "High"
  param_roll_daily_sub$biodiversity[param_roll_daily_sub$biodiversity == "low"] <- "Low"
  
  Sys.setlocale("LC_ALL", "en_GB.utf8")
  p <- ggplot(param_roll_daily_sub, aes(x = as.Date(time), y = var,
                                     linetype = biodiversity,
                                     color = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Total Basin Daily Forest ", data$name[n], "\n(Rolling 14-day Average)",  sep = "")) +
    scale_color_discrete("Afforestation\nLevel") +
    scale_linetype_discrete("Biodiversity") +
    xlab("Year") + 
    ylab("Net Primary Productivity [kgC/d]") + 
    theme_bw()
  p

  filename_figure = paste(data$filename[n], "rolling_14_day", "sum", "plantfate", "2049", sep = "_")
  filename_figure = paste(filename_figure, "eps", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  filename_figure = paste(data$filename[n], "rolling_14_day", "sum", "plantfate", "2049", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  

}

### Process basin average outputs 

dirs <- list.dirs(path = "data/ssp3_out", recursive = FALSE)
dirs <- dirs[grep("GEB_step4", dirs)]

dirs_df <- data.frame(dir = dirs,
                      biodiversity = c("na", rep(c("high", "low"), each = 6)),
                      afforestation = c("na", rep(c(0, 0.2, 0.4, 0.6, 0.8, 1), times  = 2)))

csv_names <- c("hydrology.landcover/runoff_weighted_mean_m.csv",
               "hydrology.soil/groundwater_recharge_weighted_mean_m.csv",
               "hydrology.soil/soil_moisture_weighted_mean_m.csv",
               "hydrology.soil/transpiration_weighted_mean_m.csv")

data <- data.frame(filename = csv_names,
                   filename_out = c("runoff", "groundwater_recharge", "soil_moisture", "transpiration"),
                   name = c("Runoff", "Groundwater Recharge", "Soil Moisture", "Transpiration" ),
                   yaxis = c("Runoff", "Groundwater Recharge (m)", "Soil Moisture (m)", "Transpiration (kgH20/m2)"))


for (n in 1:nrow(data)){

  dfs <- lapply(1:nrow(dirs_df), function(m){
    out <- read.csv(paste0(dirs_df$dir[m], "/", data$filename[n], sep = ""))
    out$biodiversity <- dirs_df$biodiversity[m]
    out$afforestation <- dirs_df$afforestation[m]
    return(out)
  })
  out_data <-bind_rows(dfs)
  colnames(out_data)[2] <- "var"

  p <- ggplot(out_data, aes(x = as.Date(date), y = var,
                                linetype = biodiversity,
                                colour = afforestation)) +
    geom_line() +
    facet_wrap(~afforestation, ncol = 2) +
    ggtitle(paste0("Average Daily Basin ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(data$yaxis[n])
  p


  filename_figure = paste(data$filename_out[n], "daily", "average", "basin", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  p <- ggplot(out_data, aes(x = as.Date(date), y = var,
                                linetype = biodiversity,
                                colour = afforestation)) +
    geom_line() +
    ggtitle(paste0("Average Daily Basin ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(data$yaxis[n])
  p

  filename_figure = paste(data$filename_out[n], "daily", "average", "basin", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  out_data_sub <- out_data %>%
    filter(as.Date(date) >= as.Date("01-01-2049", format= "%d-%m-%Y"))

  p <- ggplot(out_data_sub, aes(x = as.Date(date), y = var,
                                        linetype = biodiversity,
                                        color = afforestation)) +
    geom_line() +
    ggtitle(paste0("Average Daily Basin ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(data$yaxis[n])
  p

  filename_figure = paste(data$filename_out[n], "daily", "average", "basin", "2049", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")


  param_daily_one_to_one_hb <- out_data %>%
    filter(biodiversity %in% c("na", "high") & afforestation %in% c("0", "na")) %>%
    select(-one_of(c("afforestation"))) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    dplyr::mutate(biodiversity = "high")

  param_daily_one_to_one_lb <- out_data %>%
    filter(biodiversity %in% c("na", "low") & afforestation %in% c("0", "na")) %>%
    select(-one_of(c("afforestation"))) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "low")

  colnames(param_daily_one_to_one_hb)[colnames(param_daily_one_to_one_hb) == "na"] <- "GEB"
  colnames(param_daily_one_to_one_hb)[colnames(param_daily_one_to_one_hb) == "high"] <- "PlantFATE"
  colnames(param_daily_one_to_one_lb)[colnames(param_daily_one_to_one_lb) == "na"] <- "GEB"
  colnames(param_daily_one_to_one_lb)[colnames(param_daily_one_to_one_lb) == "low"] <- "PlantFATE"

  param_daily_one_to_one <- rbind(param_daily_one_to_one_hb, param_daily_one_to_one_lb)
  one_to_one_line <- data.frame(x = c(min(param_daily_one_to_one$GEB), max(param_daily_one_to_one$GEB)),
                                y = c(min(param_daily_one_to_one$PlantFATE), max(param_daily_one_to_one$PlantFATE)))


  p <- ggplot(param_daily_one_to_one, aes(x = GEB, y = PlantFATE)) +
    geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed", alpha = 0.75) +
    geom_point(alpha = 0.7) +
    facet_wrap(~biodiversity) +
    ggtitle(paste0("1-to-1 line daily Basin ", data$name[n],  sep = ""))
  p

  filename_figure = paste(data$filename_out[n], "daily", "one_to_one", "basin", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")


  ### Monthly

  param_monthly <- out_data %>%
    mutate(yr = year(date),
           mnth = month(date)) %>%
    group_by(yr, mnth, afforestation, biodiversity) %>%
    summarise(avg = mean(var)) %>%
    mutate(time = as.Date(paste(15, mnth, yr, sep = "-"), format="%d-%m-%Y"))

  p <- ggplot(param_monthly, aes(x = time, y = avg,
                                 linetype = biodiversity,
                                 color = afforestation)) +
    geom_line() +
    facet_wrap(~afforestation, ncol = 2) +
    ggtitle(paste0("Average Basin Monthly ", data$name[n],  sep = "")) +
    xlab("Time") +
    ylab(data$yaxis[n])
  p


  filename_figure = paste(data$filename_out[n], "monthly", "avg", "basin", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  p <- ggplot(param_monthly, aes(x = as.Date(time), y = avg,
                                 linetype = biodiversity,
                                 colour = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Average Basin Monthly ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(data$yaxis[n])
  p

  filename_figure = paste(data$filename_out[n], "monthly", "average", "basin", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  param_monthly_sub <- param_monthly %>%
    filter(as.Date(time) >= as.Date("01-01-2049", format= "%d-%m-%Y"))

  p <- ggplot(param_monthly_sub, aes(x = as.Date(time), y = avg,
                                linetype = biodiversity,
                                color = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Total Forest Monthly ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(data$yaxis[n])
  p

  filename_figure = paste(data$filename_out[n], "monthly", "average", "basin", "2049", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")


  ### Yearly

  param_yearly <- out_data %>%
    mutate(yr = year(date)) %>%
    group_by(yr, afforestation, biodiversity) %>%
    summarise(avg = mean(var))

  p <- ggplot(param_yearly, aes(x = yr, y = avg,
                                linetype = biodiversity,
                                color = as.factor(afforestation))) +
    geom_line() +
    facet_wrap(~afforestation, ncol = 2) +
    ggtitle(paste0("Average Basin Yearly ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(data$yaxis[n])
  p

  filename_figure = paste(data$filename_out[n], "yearly", "average", "basin", "facet", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")

  p <- ggplot(param_yearly, aes(x = yr, y = avg,
                                linetype = biodiversity,
                                colour = as.factor(afforestation))) +
    geom_line() +
    ggtitle(paste0("Average Basin Yearly ", data$name[n],  sep = "")) +
    xlab("Year") +
    ylab(data$yaxis[n])
  p

  filename_figure = paste(data$filename_out[n], "yearly", "avergae", "basin", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
}


### Make soil moisture basin wide and forest only 


## Compile basin data

n = 3

dfs <- lapply(1:nrow(dirs_df), function(m){
  out <- read.csv(paste0(dirs_df$dir[m], "/", data$filename[n], sep = ""))
  out$biodiversity <- dirs_df$biodiversity[m]
  out$afforestation <- dirs_df$afforestation[m]
  return(out)
})
out_data <-bind_rows(dfs)
colnames(out_data)[2] <- "var"



param_yearly <- out_data %>%
  mutate(yr = year(date)) %>%
  group_by(yr, afforestation, biodiversity) %>%
  summarise(avg = mean(var))

param_yearly$afforestation[param_yearly$afforestation == "na"] <- "N/A" 
param_yearly$biodiversity[param_yearly$biodiversity == "high"] <- "High"
param_yearly$biodiversity[param_yearly$biodiversity == "low"] <- "Low"
param_yearly$biodiversity[param_yearly$biodiversity == "na"] <- "Default\nGEB"

param_yearly$biodiversity <- factor(param_yearly$biodiversity, levels = c("High", "Low", "Default\nGEB"))



p <- ggplot(param_yearly, aes(x = yr, y = avg,
                              linetype = biodiversity,
                              color = as.factor(afforestation))) +
  geom_line() +
  ggtitle(paste0("Average Basin Yearly ", data$name[n],  sep = "")) +
  scale_color_discrete("Afforestation\nLevel") +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") + 
  ylab(data$yaxis[n]) + 
  theme_bw()
p


## forest data

n = 1


list.files("out/ssp3_preproc/")

parameters <- c("soil_moisture", "transpiration", "groundwater_recharge")

data <- data.frame(filename = parameters, 
                   name = c("Normalized Soil Moisture", "Transpiration (Daily Average)", "Groundwater Recharge"),
                   yaxis = c("Normalized Soil Moisture (m/m)", "Transpiration (kgH20/m2)", "Groundwater Recharge (m)"))

figure_dir = "out/ssp3/figures"

param_yearly = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_yearly.csv", sep = ""))
param_yearly$afforestation[param_yearly$afforestation == "10.0"] <- "1.0"
colnames(param_yearly)[2] <- "var"

param_yearly$afforestation[param_yearly$afforestation == "na"] <- "N/A" 
param_yearly$biodiversity[param_yearly$biodiversity == "high"] <- "High"
param_yearly$biodiversity[param_yearly$biodiversity == "low"] <- "Low"
param_yearly$biodiversity[param_yearly$biodiversity == "na"] <- "Default\nGEB"

param_yearly$biodiversity <- factor(param_yearly$biodiversity, levels = c("High", "Low", "Default\nGEB"))



p <- ggplot(param_yearly, aes(x = year, y = var, 
                              linetype = biodiversity,
                              colour = afforestation)) + 
  geom_line() + 
  ggtitle(paste0("Average Annual Forest ", data$name[n],  sep = "")) + 
  scale_color_discrete("Afforestation\nLevel") +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") + 
  ylab("Normalized Soil Moisture [m/m]") + 
  theme_bw()
p

filename_figure = paste(data$filename[n], "annual", "average", "forest", "facet", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste(data$filename[n], "annual", "average", "forest", "facet", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")


#### Now combine forest transpiration 



n = 2


list.files("out/ssp3_preproc/")

parameters <- c("soil_moisture", "transpiration", "groundwater_recharge")

data <- data.frame(filename = parameters, 
                   name = c("Normalized Soil Moisture", "Transpiration\n(Daily Average)", "Groundwater Recharge"),
                   yaxis = c("Normalized Soil Moisture [m/m)]", "Transpiration [kgH20/m2]", "Groundwater Recharge [m]"))

figure_dir = "out/ssp3/figures"

param_yearly = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_forest_average_yearly.csv", sep = ""))
param_yearly$afforestation[param_yearly$afforestation == "10.0"] <- "1.0"
colnames(param_yearly)[2] <- "var"

param_yearly$afforestation[param_yearly$afforestation == "na"] <- "N/A" 
param_yearly$biodiversity[param_yearly$biodiversity == "high"] <- "High"
param_yearly$biodiversity[param_yearly$biodiversity == "low"] <- "Low"
param_yearly$biodiversity[param_yearly$biodiversity == "na"] <- "Default\nGEB"

param_yearly$biodiversity <- factor(param_yearly$biodiversity, levels = c("High", "Low", "Default\nGEB"))


p_transpiration_ave <- ggplot(param_yearly, aes(x = year, y = var, 
                              linetype = biodiversity,
                              colour = afforestation)) + 
  geom_line() + 
  ggtitle(paste0("Average Annual Forest ", data$name[n],  sep = "")) + 
  scale_color_discrete("Afforestation\nLevel") +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") + 
  ylab(data$yaxis[n]) + 
  theme_bw()
p_transpiration_ave



n = 2
parameters <- c("biomass", "transpiration", "NPP")

data <- data.frame(filename = parameters,
                   name = c("Biomass", "Transpiration", "NPP"),
                   yaxis = c("Biomass [kgC]", "Transpiration [kgH20]", "NPP [kgC]"))

param_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_plantfate_basin_sum_daily.csv", sep = "")) %>%
    drop_na()
  param_daily$afforestation[param_daily$afforestation == 10] <- 1.0
  param_daily <- param_daily 
  colnames(param_daily)[2] <- "var"
  param_daily <- param_daily %>%
    dplyr::filter(var != 0)

  yaxis = paste(data$yaxis[n], "per day")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }


  param_yearly <- param_daily %>%
    mutate(yr = year(time)) %>%
    group_by(yr, afforestation, biodiversity) %>%
    summarise(summed = sum(var))

  yaxis = paste(data$yaxis[n], "per year")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }
  
  
  param_yearly$afforestation[param_yearly$afforestation == "na"] <- "N/A" 
  param_yearly$biodiversity[param_yearly$biodiversity == "high"] <- "High"
  param_yearly$biodiversity[param_yearly$biodiversity == "low"] <- "Low"
  param_yearly$biodiversity[param_yearly$biodiversity == "na"] <- "Default\nGEB"
  
  param_yearly$biodiversity <- factor(param_yearly$biodiversity, levels = c("High", "Low", "Default\nGEB"))
  param_yearly$afforestation <- as.factor(param_yearly$afforestation)
  
  p_transpiration_total <- ggplot(param_yearly, aes(x = yr, y = summed,
                                 linetype = biodiversity,
                                 color = afforestation)) +
    geom_line() +
    ggtitle(paste0("Total Forest Yearly ", data$name[n],  sep = "")) +
    scale_color_discrete("Afforestation\nLevel", guide = "none") +
    xlab("Year") +
    ylab(yaxis) +
    scale_linetype_discrete("Biodiversity", guide="none") +
    theme(legend.position="none") +
    theme_bw()
  p_transpiration_total

  
p <- ggpubr::ggarrange(p_transpiration_total, p_transpiration_ave, labels = c("(a)","(b)"), widths = c(3,4))
p  


filename_figure = paste("forest_transpiration_both")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("forest_transpiration_both")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")
  


## Combine NPP and Biomass 



parameters <- c("biomass", "transpiration", "NPP")

data <- data.frame(filename = parameters,
                   name = c("Biomass", "Transpiration", "NPP"),
                   yaxis = c("Biomass [kgC]", "Transpiration [kgH20]", "NPP [kgC]"))

### NPP
n = 3
param_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_plantfate_basin_sum_daily.csv", sep = ""))
param_daily$afforestation[param_daily$afforestation == 10] <- 1.0
colnames(param_daily)[2] <- "var"

param_yearly <- param_daily %>%
  mutate(yr = year(time)) %>%
  group_by(yr, afforestation, biodiversity) %>%
  summarise(summed = sum(var))

param_yearly$biodiversity[param_yearly$biodiversity == "high"] <- "High"
param_yearly$biodiversity[param_yearly$biodiversity == "low"] <- "Low"

param_yearly$biodiversity <- factor(param_yearly$biodiversity, levels = c("High", "Low"))
param_yearly$afforestation <- as.factor(param_yearly$afforestation)

p_NPP_total <- ggplot(param_yearly, aes(x = yr, y = summed,
                                                  linetype = biodiversity,
                                                  color = afforestation)) +
  geom_line() +
  ggtitle(paste0("Total Forest Yearly \nNet Primary Productivity",  sep = "")) +
  scale_color_discrete("Afforestation\nLevel", guide = "none") +
  xlab("Year") +
  ylab("NPP [kgC/y]") +
  scale_linetype_discrete("Biodiversity", guide="none") +
  theme(legend.position="none") +
  theme_bw()
p_NPP_total


### Biomass
n = 1
param_daily = read.csv(paste0("out/ssp3_preproc/", data$filename[n], "_plantfate_basin_sum_daily.csv", sep = ""))
param_daily$afforestation[param_daily$afforestation == 10] <- 1.0
colnames(param_daily)[2] <- "var"
param_daily <- param_daily %>%
  dplyr::filter(var != 0)

param_yearly <- param_daily %>%
  mutate(yr = year(time)) %>%
  group_by(yr, afforestation, biodiversity) %>%
  summarise(summed = sum(var))

param_yearly$biodiversity[param_yearly$biodiversity == "high"] <- "High"
param_yearly$biodiversity[param_yearly$biodiversity == "low"] <- "Low"

param_yearly$biodiversity <- factor(param_yearly$biodiversity, levels = c("High", "Low"))
param_yearly$afforestation <- as.factor(param_yearly$afforestation)

p_biomass_total <- ggplot(param_yearly, aes(x = yr, y = summed,
                                        linetype = biodiversity,
                                        color = afforestation)) +
  geom_line() +
  ggtitle(paste0("Total Forest Yearly ", data$name[n],  sep = "")) +
  scale_color_discrete("Afforestation\nLevel") +
  scale_linetype_discrete("Biodiversity") +
  xlab("Year") +
  ylab("Biomass [kgC]") +
  theme_bw()
p_biomass_total

p <- ggpubr::ggarrange(p_NPP_total, p_biomass_total, labels = c("(a)","(b)"), widths = c(3,4))
p  

filename_figure = paste("forest_npp_biodiversity_both")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("forest_npp_biodiversity_both")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")
