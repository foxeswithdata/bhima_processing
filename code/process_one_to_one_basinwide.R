rm(list = ls())
library(tidyverse)

## Read in file

list.files("out/ssp3_preproc/not_averaged/")

parameters <- c("soil_moisture", "transpiration", "groundwater_recharge")

data <- data.frame(filename = parameters, 
                   name = c("Soil Moisture", "Transpiration (Daily Average)", "Groundwater Recharge"),
                   yaxis = c("Soil Moisture (m)", "Transpiration (kgH20/m2)", "Groundwater Recharge (m)"))

figure_dir = "out/ssp3/figures"


for (n in 1:nrow(data)){
  
  #Process yearly data
  
  param_daily = read.csv(paste0("out/ssp3_preproc/not_averaged/", data$filename[n], "_forest_daily.csv", sep = ""))
  colnames(param_daily)[2] <- "var"
  
  param_daily_one_to_one_hb <- param_daily %>%
    select(-one_of(c("afforestation"))) %>%
    pivot_wider(values_from = var, names_from = biodiversity)
  
  colnames(param_yearly_one_to_one_hb)[colnames(param_yearly_one_to_one_hb) == "na"] <- "GEB"
  colnames(param_yearly_one_to_one_hb)[colnames(param_yearly_one_to_one_hb) == "high"] <- "PlantFATE"
  colnames(param_yearly_one_to_one_lb)[colnames(param_yearly_one_to_one_lb) == "na"] <- "GEB"
  colnames(param_yearly_one_to_one_lb)[colnames(param_yearly_one_to_one_lb) == "low"] <- "PlantFATE"
  
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
}