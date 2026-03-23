rm(list = ls())

library(tidyverse)



## Read in file

list.files("out/ssp3_preproc/spinup/")

parameters <- c("soil_moisture", "transpiration", "groundwater_recharge")

data <- data.frame(filename = parameters, 
                   name = c("Soil Moisture", "Transpiration", "Groundwater Recharge"),
                   yaxis = c("Soil Moisture (m)", "Transpiration (kgH20/m2)", "Groundwater Recharge (m)"))

figure_dir = "out/ssp3/figures/spinup/"

### Forest averages
for (n in 1:nrow(data)){
  
  #Process yearly data
  param_yearly = read.csv(paste0("out/ssp3_preproc/spinup/", data$filename[n], "_forest_average_yearly.csv", sep = ""))
  colnames(param_yearly)[2] <- "var"
  
  p <- ggplot(param_yearly, aes(x = year, y = var, 
                                color = biodiversity)) + 
    geom_line() + 
    ggtitle(paste0("Average Annual Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename[n], "annual", "average", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  param_yearly_one_to_one_hb <- param_yearly %>%
    filter(biodiversity %in% c("na", "high")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "high") %>%
    select(-one_of(c("spatial_ref", "crs")))
  
  param_yearly_one_to_one_lb <- param_yearly %>%
    filter(biodiversity %in% c("na", "low")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "low") %>%
    select(-one_of(c("spatial_ref", "crs")))
  
  colnames(param_yearly_one_to_one_hb)[c(2,3)] <- c("GEB", "PlantFATE") 
  colnames(param_yearly_one_to_one_lb)[c(2,3)] <- c("GEB", "PlantFATE") 
  
  param_yearly_one_to_one <- rbind(param_yearly_one_to_one_hb, param_yearly_one_to_one_lb)
  one_to_one_line <- data.frame(x = c(min(param_yearly_one_to_one$GEB), max(param_yearly_one_to_one$GEB)),
                                y = c(min(param_yearly_one_to_one$PlantFATE), max(param_yearly_one_to_one$PlantFATE)))
  
  
  p <- ggplot(param_yearly_one_to_one, aes(x = GEB, y = PlantFATE)) + 
    geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed", alpha = 0.75) + 
    geom_point(alpha = 0.7) +
    facet_wrap(~biodiversity) + 
    ggtitle(paste0("1-to-1 line yearly Forest ", data$name[n],  sep = ""))
  p
  
  filename_figure = paste(data$filename[n], "annual", "one_to_one", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  #Process monthly data
  param_monthly = read.csv(paste0("out/ssp3_preproc/spinup/", data$filename[n], "_forest_average_monthly.csv", sep = "")) 
  param_monthly <- param_monthly %>%
    mutate(my_date = paste(15, month, year, sep = '-')) %>% 
    mutate(my_date = as.Date(my_date, format = '%d-%m-%Y', origin = '1970-01-01')) %>%
    select(-one_of(c("spatial_ref", "crs")))
  colnames(param_monthly)[3] <- "var"
  
  p <- ggplot(param_monthly, aes(x = my_date, y = var, 
                                 color = biodiversity)) + 
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
  
  param_monthly_one_to_one_hb <- param_monthly %>%
    filter(biodiversity %in% c("na", "high")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "high")
  
  param_monthly_one_to_one_lb <- param_monthly %>%
    filter(biodiversity %in% c("na", "low")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "low")
  
  colnames(param_monthly_one_to_one_hb)[c(4,5)] <- c("GEB", "PlantFATE") 
  colnames(param_monthly_one_to_one_lb)[c(4,5)] <- c("GEB", "PlantFATE") 
  
  param_monthly_one_to_one <- rbind(param_monthly_one_to_one_hb, param_monthly_one_to_one_lb)
  one_to_one_line <- data.frame(x = c(min(param_monthly_one_to_one$GEB), max(param_monthly_one_to_one$GEB)),
                                y = c(min(param_monthly_one_to_one$PlantFATE), max(param_monthly_one_to_one$PlantFATE)))
  
  
  p <- ggplot(param_monthly_one_to_one, aes(x = GEB, y = PlantFATE)) + 
    geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed", alpha = 0.75) + 
    geom_point(alpha = 0.5) +
    facet_wrap(~biodiversity) + 
    ggtitle(paste0("1-to-1 line monthly Forest ", data$name[n],  sep = ""))
  p
  
  filename_figure = paste(data$filename[n], "monthly", "one_to_one", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  #Process rolling average data
  param_roll_daily = read.csv(paste0("out/ssp3_preproc/spinup/", data$filename[n], "_forest_rolling_average_14_days.csv", sep = ""))
  param_roll_daily <- param_roll_daily[,c(1, 4:ncol(param_roll_daily))]
  colnames(param_roll_daily)[2] <- "var"
  
  p <- ggplot(param_roll_daily, aes(x = as.Date(time), y = var, 
                                    color = biodiversity)) + 
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
  
  param_daily_rolling_one_to_one_hb <- param_roll_daily %>%
    filter(biodiversity %in% c("na", "high")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "high") 
  
  param_daily_rolling_one_to_one_lb <- param_roll_daily %>%
    filter(biodiversity %in% c("na", "low")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "low") 
  
  colnames(param_daily_rolling_one_to_one_hb)[c(2,3)] <- c("GEB", "PlantFATE") 
  colnames(param_daily_rolling_one_to_one_lb)[c(2,3)] <- c("GEB", "PlantFATE") 
  
  param_daily_rolling_one_to_one <- rbind(param_daily_rolling_one_to_one_hb, param_daily_rolling_one_to_one_lb)
  one_to_one_line <- data.frame(x = c(min(param_daily_rolling_one_to_one$GEB, na.rm = TRUE), max(param_daily_rolling_one_to_one$GEB,  na.rm = TRUE)),
                                y = c(min(param_daily_rolling_one_to_one$PlantFATE,  na.rm = TRUE), max(param_daily_rolling_one_to_one$PlantFATE,  na.rm = TRUE)))
  
  p <- ggplot(param_daily_rolling_one_to_one, aes(x = GEB, y = PlantFATE)) + 
    geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed") + 
    geom_point(alpha = 0.05) +
    facet_wrap(~biodiversity) + 
    ggtitle(paste0("1-to-1 line Daily Rolling Average Forest ", data$name[n],  sep = ""))
  p
  
  filename_figure = paste(data$filename[n], "rolling_daily", "one_to_one", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  #Process average daily data
  param_daily = read.csv(paste0("out/ssp3_preproc/spinup/", data$filename[n], "_forest_average_daily.csv", sep = ""))
  param_daily <- param_daily[,c(1, 4:ncol(param_daily))]
  colnames(param_daily)[2] <- "var"
  
  param_daily_one_to_one_hb <- param_daily %>%
    filter(biodiversity %in% c("na", "high")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "high") 
  
  param_daily_one_to_one_lb <- param_daily %>%
    filter(biodiversity %in% c("na", "low")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "low") 
  
  colnames(param_daily_one_to_one_hb)[c(2,3)] <- c("GEB", "PlantFATE") 
  colnames(param_daily_one_to_one_lb)[c(2,3)] <- c("GEB", "PlantFATE") 
  
  param_daily_one_to_one <- rbind(param_daily_one_to_one_hb, param_daily_one_to_one_lb)
  one_to_one_line <- data.frame(x = c(min(param_daily_one_to_one$GEB, na.rm = TRUE), max(param_daily_one_to_one$GEB,  na.rm = TRUE)),
                                y = c(min(param_daily_one_to_one$PlantFATE,  na.rm = TRUE), max(param_daily_one_to_one$PlantFATE,  na.rm = TRUE)))
  
  p <- ggplot(param_daily_one_to_one, aes(x = GEB, y = PlantFATE)) + 
    geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed") + 
    geom_point(alpha = 0.05) +
    facet_wrap(~biodiversity) + 
    ggtitle(paste0("1-to-1 line Daily Average Forest ", data$name[n],  sep = ""))
  p
  
  filename_figure = paste(data$filename[n], "daily", "one_to_one", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  #Process monsoon season data
  
  param_monsoon = read.csv(paste0("out/ssp3_preproc/spinup/", data$filename[n], "_forest_average_monsoon.csv", sep = "")) %>%
    drop_na()
  colnames(param_monsoon)[2] <- "var"
  
  p <- ggplot(param_monsoon, aes(x = year, y = var, 
                                 color = biodiversity)) + 
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
  
  #Process dry season data
  
  param_dry = read.csv(paste0("out/ssp3_preproc/spinup/", data$filename[n], "_forest_average_dry_season.csv", sep = "")) %>%
    drop_na()
  colnames(param_dry)[2] <- "var"
  
  p <- ggplot(param_dry, aes(x = year, y = var, 
                             color = biodiversity)) + 
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
}


### PlantFATE sums

parameters <- c("biomass", "transpiration", "NPP")

data <- data.frame(filename = parameters, 
                   name = c("Biomass", "Transpiration", "NPP"),
                   yaxis = c("Biomass kgC", "Transpiration (kgH20/day)", "NPP kgC/day"))

for (n in 1:nrow(data)){
  
  #Process daily data
  param_daily = read.csv(paste0("out/ssp3_preproc/spinup/", data$filename[n], "_plantfate_basin_sum_daily.csv", sep = "")) %>%
    drop_na()
  param_daily <- param_daily %>%
    select(-c("spatial_ref", "crs"))
  colnames(param_daily)[2] <- "var"
  param_daily <- param_daily %>%
    dplyr::filter(var != 0)
  
  yaxis = paste(data$yaxis[n], "per day")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }
  
  p <- ggplot(param_daily, aes(x = as.Date(time), 
                               y = var, 
                               color = biodiversity)) + 
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
  
  ### Monthly 
  
  param_monthly <- param_daily %>% 
    mutate(yr = year(time),
           mnth = month(time)) %>%
    group_by(yr, mnth, biodiversity) %>%
    summarise(summed = sum(var)) %>%
    mutate(time = as.Date(paste(15, mnth, yr, sep = "-"), format = "%d-%m-%Y"))
  
  yaxis = paste(data$yaxis[n], "per month")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }
  
  p <- ggplot(param_monthly, aes(x = as.Date(time), y = summed, 
                                 color = biodiversity)) + 
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
  
  ### Yearly 
  
  param_yearly <- param_daily %>% 
    mutate(yr = year(time)) %>%
    group_by(yr, biodiversity) %>%
    summarise(summed = sum(var))
  
  yaxis = paste(data$yaxis[n], "per month")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }
 
  p <- ggplot(param_yearly, aes(x = yr, y = summed, 
                                color = biodiversity)) + 
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
  param_roll_daily = read.csv(paste0("out/ssp3_preproc/spinup/", data$filename[n], "_plantfate_basin_sum_daily_rolling.csv", sep = "")) %>%
    drop_na()
  param_roll_daily <- param_roll_daily[,c(1, 4:ncol(param_roll_daily))]
  colnames(param_roll_daily)[2] <- "var"
  
  yaxis = paste(data$yaxis[n], "per day")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }
  
  
  p <- ggplot(param_roll_daily, aes(x = as.Date(time), y = var, 
                                    color = biodiversity)) + 
    geom_line() + 
    ggtitle(paste0("Daily (Rolling 14 day Average) Forest ", data$name[n],  sep = "")) + 
    xlab("Time") + 
    ylab(yaxis)
  p
  
  filename_figure = paste(data$filename[n], "rolling_14_day", "sum", "forest", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
}

### Process basin average outputs 

dirs <- list.dirs(path = "data/ssp3_out", recursive = FALSE)
dirs <- dirs[grep("GEB_step3_", dirs)]

dirs_df <- data.frame(dir = dirs,
                      biodiversity = c("na", "high", "low"))

csv_names <- c("hydrology.landcover/runoff_weighted_mean_m.csv", 
               "hydrology.soil/soil_moisture_weighted_mean_m.csv",
               "hydrology.soil/transpiration_weighted_mean_m.csv",
               "hydrology.soil/groundwater_recharge_weighted_mean_m.csv")

data <- data.frame(filename = csv_names, 
                   filename_out = c("runoff", "groundwater_recharge", "soil_moisture", "transpiration"),
                   name = c("Runoff", "Groundwater Recharge", "Soil Moisture", "Transpiration" ),
                   yaxis = c("Runoff", "Groundwater Recharge (m)", "Soil Moisture (m)", "Transpiration (kgH20/m2)"))



for (n in 1:nrow(data)){
  
  dfs <- lapply(1:nrow(dirs_df), function(m){
    out <- read.csv(paste0(dirs_df$dir[m], "/", data$filename[n], sep = ""))
    out$biodiversity <- dirs_df$biodiversity[m]
    return(out)
  })
  out_data <-bind_rows(dfs)
  colnames(out_data)[2] <- "var"
  
  p <- ggplot(out_data, aes(x = as.Date(date), y = var, 
                            color = biodiversity)) + 
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
  
  param_daily_one_to_one_hb <- out_data %>%
    filter(biodiversity %in% c("na", "high")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    dplyr::mutate(biodiversity = "high") 
  
  param_daily_one_to_one_lb <- out_data %>%
    filter(biodiversity %in% c("na", "low")) %>%
    pivot_wider(values_from = var, names_from = biodiversity) %>%
    mutate(biodiversity = "low")
  
  colnames(param_daily_one_to_one_hb)[c(2,3)] <- c("GEB", "PlantFATE") 
  colnames(param_daily_one_to_one_lb)[c(2,3)] <- c("GEB", "PlantFATE") 
  
  param_daily_one_to_one <- rbind(param_daily_one_to_one_hb, param_daily_one_to_one_lb)
  one_to_one_line <- data.frame(x = c(min(param_daily_one_to_one$GEB), max(param_daily_one_to_one$GEB)),
                                y = c(min(param_daily_one_to_one$PlantFATE), max(param_daily_one_to_one$PlantFATE)))
  
  p <- ggplot(param_daily_one_to_one, aes(x = GEB, y = PlantFATE)) + 
    geom_line(data = one_to_one_line, aes(x = x, y = y), linetype = "dashed", alpha = 0.75) + 
    geom_point(alpha = 0.7) +
    facet_wrap(~biodiversity) + 
    ggtitle(paste0("1-to-1 line yearly Basin ", data$name[n],  sep = ""))
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
    group_by(yr, mnth, biodiversity) %>%
    summarise(avg = mean(var)) %>%
    mutate(time = as.Date(paste(15, mnth, yr, sep = "-"), format = "%d-%m-%Y"))
  
  p <- ggplot(param_monthly, aes(x = as.Date(time), y = avg, 
                                 color = biodiversity)) + 
    geom_line() + 
    ggtitle(paste0("Average Basin Monthly ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename_out[n], "monthly", "avg", "basin", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  ### Yearly 
  param_yearly <- out_data %>% 
    mutate(yr = year(date)) %>%
    group_by(yr, biodiversity) %>%
    summarise(avg = mean(var))
  
  p <- ggplot(param_yearly, aes(x = yr, y = avg, 
                                color = biodiversity)) + 
    geom_line() + 
    ggtitle(paste0("Average Basin Yearly ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  filename_figure = paste(data$filename_out[n], "yearly", "avg", "basin", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
}  

