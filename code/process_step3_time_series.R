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
  
  file_figure <- tempfile(paste(data$filename[n], "annual", "average", "forest", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  
  
  #Process monthly data
  param_monthly = read.csv(paste0("out/ssp3_preproc/spinup/", data$filename[n], "_forest_average_monthly.csv", sep = "")) 
  param_monthly <- param_monthly %>%
    mutate(my_date = paste(15, month, year, sep = '-')) %>% 
    mutate(my_date = as.Date(my_date, format = '%d-%m-%Y', origin = '1970-01-01'))
  colnames(param_monthly)[3] <- "var"
  
  p <- ggplot(param_monthly, aes(x = my_date, y = var, 
                                 color = biodiversity)) + 
    geom_line() + 
    ggtitle(paste0("Average Monthly Forest ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  file_figure <- tempfile(paste(data$filename[n], "monthly", "average", "forest", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
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
  
  file_figure <- tempfile(paste(data$filename[n], "rolling_14_day", "average", "forest", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
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
  
  file_figure <- tempfile(paste(data$filename[n], "monsoon", "average", "forest", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
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
  
  file_figure <- tempfile(paste(data$filename[n], "dry_season", "average", "forest", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
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
  param_daily <- param_daily[2:nrow(param_daily),c(1, 4:ncol(param_daily))]
  colnames(param_daily)[2] <- "var"
  
  yaxis = paste(data$yaxis[n], "per day")
  if(data$filename[n] == "biomass"){
    yaxis = data$yaxis[n]
  }
  
  p <- ggplot(param_daily, aes(x = as.Date(time), y = var, 
                               color = biodiversity)) + 
    geom_line() + 
    ggtitle(paste0("Total Forest Daily ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(yaxis)
  p
  
  file_figure <- tempfile(paste(data$filename[n],"daily", "sum", "plantfate", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  ### Monthly 
  
  param_monthly <- param_daily %>% 
    mutate(yr = year(time),
           mnth = month(time)) %>%
    group_by(yr, mnth, biodiversity) %>%
    summarise(summed = sum(var)) %>%
    mutate(time = as.Date(paste(15, mnth, yr, sep = "-")))
  
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
  
  file_figure <- tempfile(paste(data$filename[n], "monthly", "sum", "plantfate", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
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
  
  file_figure <- tempfile(paste(data$filename[n], "yearly", "sum", "plantfate", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
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
  
  file_figure <- tempfile(paste(data$filename[n], "rolling_14_day", "sum", "forest", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
}

### Process basin average outputs 

dirs <- list.dirs(path = "data/ssp3_out", recursive = FALSE)
dirs <- dirs[grep("GEB_step3_", dirs)]

dirs_df <- data.frame(dir = dirs,
                      biodiversity = c("no PF", "high", "low"))

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
  
  file_figure <- tempfile(paste(data$filename_out[n], "daily", "average", "basin", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  ### Monthly 
  
  param_monthly <- out_data %>% 
    mutate(yr = year(date),
           mnth = month(date)) %>%
    group_by(yr, mnth, biodiversity) %>%
    summarise(avg = mean(var)) %>%
    mutate(time = as.Date(paste(15, mnth, yr, sep = "-")))
  
  p <- ggplot(param_monthly, aes(x = as.Date(time), y = avg, 
                                 color = biodiversity)) + 
    geom_line() + 
    ggtitle(paste0("Average Forest Monthly ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  file_figure <- tempfile(paste(data$filename_out[n], "monthly", "avg", "forest", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
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
    ggtitle(paste0("Average Forest Yearly ", data$name[n],  sep = "")) + 
    xlab("Year") + 
    ylab(data$yaxis[n])
  p
  
  file_figure <- tempfile(paste(data$filename_out[n], "yearly", "avg", "forest", sep = "_"), tmpdir = figure_dir, fileext = ".png")
  ggsave(file_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
}  

