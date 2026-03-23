rm(list = ls())

library(tidyverse)
library(ggpubr)

forest_cells <- read.csv("test_plantFATE_out/data/simulation_list.csv")
forest_cells <- unique(select(forest_cells, c("new_forest", "cell")))

for (i in 1:nrow(forest_cells)){

  figure_dir = paste("test_plantFATE_out/output/test_individual_cells/cell_", forest_cells$cell[i], "/", sep = "")
  dir.create(figure_dir, showWarnings = FALSE, recursive = TRUE)
  
  results_directory = ifelse(forest_cells$new_forest[i], "output/cell", "simulation_root/default/plantFATE/cell")
  results_directory_hb = paste(results_directory, forest_cells$cell[i], "hb", sep = "_")
  results_directory_lb = paste(results_directory, forest_cells$cell[i], "lb", sep = "_")
  
  community_level_out_hb <- read.csv(paste(results_directory_hb, "/D_PFATE.csv", sep = ""))
  community_level_out_hb$date <- as.Date(paste(community_level_out_hb$IYEAR, community_level_out_hb$MON, community_level_out_hb$DAY, sep = "-"))
  community_level_out_hb$biodiversity <- "High"
  community_level_out_lb <- read.csv(paste(results_directory_lb, "/D_PFATE.csv", sep = ""))
  community_level_out_lb$date <- as.Date(paste(community_level_out_lb$IYEAR, community_level_out_lb$MON, community_level_out_lb$DAY, sep = "-"))
  community_level_out_lb$biodiversity <- "Low"
  community_level_out <- rbind(community_level_out_lb, community_level_out_hb)
  community_level_out$biodiversity <- factor(community_level_out$biodiversity, levels = c("High", "Low"))
  
  
  species_data_mean_out_hb =  read.csv(paste(results_directory_hb, "/Y_mean_PFATE.csv", sep = ""))
  species_data_mean_out_hb$biodiversity <- "High"
  species_data_mean_out_lb =  read.csv(paste(results_directory_lb, "/Y_mean_PFATE.csv", sep = ""))
  species_data_mean_out_lb$biodiversity <- "Low"
  species_data_mean_out <- rbind(species_data_mean_out_lb, species_data_mean_out_hb)
  species_data_mean_out$biodiversity <- factor(species_data_mean_out$biodiversity, levels = c("High", "Low"))
  
  species_data_out_hb = read.csv(paste(results_directory_hb, "/Y_PFATE.csv", sep = ""))
  species_data_out_hb$biodiversity <- "High"
  species_data_out_lb =  read.csv(paste(results_directory_lb, "/Y_PFATE.csv", sep = ""))
  species_data_out_lb$biodiversity <- "Low"
  species_data_out <- rbind(species_data_out_hb, species_data_out_lb)
  species_data_out$biodiversity <- factor(species_data_out$biodiversity, levels = c("High", "Low"))
  
  species_data_out$PID <- sapply(species_data_out$PID, function(spn){
    spn <- str_sub(spn, end = -3)
    return(spn)
  })
  
  environment_data <- read.csv(paste("test_plantFATE_out/data/GEB_step4_lb_af_10/", "/env_data_cell_2838.csv", sep = ""))
  environment_data$Date <- as.Date(environment_data$Date)
  
  head(community_level_out)
  head(environment_data)

  p <- ggplot(species_data_mean_out, aes(x = YEAR, y=LAI, color = biodiversity))+
    geom_line() +
    scale_color_discrete("Biodiversity") +
    ggtitle(paste0("Leaf Area Index Cell ", forest_cells$cell[i], sep = "")) +
    xlab("Date") +
    ylab("LAI") + 
    theme_bw()
  p
  
  filename_figure = paste("LAI", "cell", forest_cells$cell[i], sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  filename_figure = paste("LAI", "cell", forest_cells$cell[i], sep = "_")
  filename_figure = paste(filename_figure, "eps", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  p <- ggplot(community_level_out, aes(x = YEAR, y=NPP, color = biodiversity))+
    geom_line() +
    scale_color_discrete("Biodiversity") +
    ggtitle(paste0("Net Primary Productivity Cell ", forest_cells$cell[i], sep = "")) +
    xlab("Date") +
    ylab("NPP [kgCm-2y-1]") + 
    theme_bw()
  p
  
  filename_figure = paste("NPP", "cell", forest_cells$cell[i], sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  filename_figure = paste("NPP", "cell", forest_cells$cell[i], sep = "_")
  filename_figure = paste(filename_figure, "eps", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  community_level_out_sub <- community_level_out %>%
    filter(date > as.Date("2044-12-31"))
  
  p <- ggplot(community_level_out_sub, aes(x = date, y=GPP, color = biodiversity))+
    geom_line() +
    scale_color_discrete("Biodiversity") +
    ggtitle(paste0("Gross Primary Productivity Cell ", forest_cells$cell[i], " years 2045-2050", sep = "")) +
    xlab("Date") +
    ylab("GPP [kgCm-2y-1]") + 
    theme_bw()
  p
  
  filename_figure = paste("GPP", "cell", forest_cells$cell[i], "2045", "2050", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  filename_figure = paste("GPP", "cell", forest_cells$cell[i], "2045", "2050", sep = "_")
  filename_figure = paste(filename_figure, "eps", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  p <- ggplot(community_level_out_sub, aes(x = date, y=NPP, color = biodiversity))+
    geom_line() +
    scale_color_discrete("Biodiversity") +
    ggtitle(paste0("Net Primary Productivity Cell ", forest_cells$cell[i], " years 2045-2050", sep = "")) +
    xlab("Date") +
    ylab("NPP [kgCm-2y-1]") + 
    theme_bw()
  p
  
  filename_figure = paste("NPP", "cell", forest_cells$cell[i], "2045", "2050", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  filename_figure = paste("NPP", "cell", forest_cells$cell[i], "2045", "2050", sep = "_")
  filename_figure = paste(filename_figure, "eps", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  
  environment_data_sub <- environment_data %>%
    filter(Date > as.Date("2044-12-31"))
  
  p_PAR <- ggplot(environment_data_sub, aes(x = Date, y=PAR))+
    geom_line() +
    xlab("Date") +
    ylab("PAR [umolm-2s-1]") + 
    theme_bw()
  p_Temp <- ggplot(environment_data_sub, aes(x = Date, y=Temp))+
    geom_line()+
    xlab("Date") +
    ylab("Temperature [C]") + 
    theme_bw()
  p_VPD <- ggplot(environment_data_sub, aes(x = Date, y=VPD))+
    geom_line()+
    xlab("Date") +
    ylab("Vapour Pressure Deficit [hPa]") + 
    theme_bw()
  p_SWP <- ggplot(environment_data_sub, aes(x = Date, y=-SWP))+
    geom_line()+
    xlab("Date") +
    ylab("Soil Water Potential [-MPa]") + 
    theme_bw()
  
  p <- ggarrange(p_Temp, p_PAR, p_VPD, p_SWP, 
                 ncol = 2, nrow = 2, 
                 labels = c("(a)", "(b)", "(c)", "(d)"))
  p
  
  filename_figure = paste("environment", "cell", forest_cells$cell[i], "2045", "2050", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  filename_figure = paste("environment", "cell", forest_cells$cell[i], "2045", "2050", sep = "_")
  filename_figure = paste(filename_figure, "eps", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  
  environment_data_sub <- environment_data %>%
    filter(Date > as.Date("2045-12-31") & Date <= as.Date("2046-12-31"))
  
  p_PAR <- ggplot(environment_data_sub, aes(x = Date, y=PAR))+
    geom_line() +
    xlab("Date") +
    ylab("PAR [umolm-2s-1]") + 
    theme_bw()
  p_Temp <- ggplot(environment_data_sub, aes(x = Date, y=Temp))+
    geom_line()+
    xlab("Date") +
    ylab("Temperature [C]") + 
    theme_bw()
  p_VPD <- ggplot(environment_data_sub, aes(x = Date, y=VPD))+
    geom_line()+
    xlab("Date") +
    ylab("Vapour Pressure Deficit [hPa]") + 
    theme_bw()
  p_SWP <- ggplot(environment_data_sub, aes(x = Date, y=-SWP))+
    geom_line()+
    xlab("Date") +
    ylab("Soil Water Potential [-MPa]") + 
    theme_bw()
  
  p <- ggarrange(p_Temp, p_PAR, p_VPD, p_SWP, 
                 ncol = 2, nrow = 2, 
                 labels = c("(a)", "(b)", "(c)", "(d)"))
  p
  
  filename_figure = paste("environment", "cell", forest_cells$cell[i], "2046", sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  filename_figure = paste("environment", "cell", forest_cells$cell[i], "2046", sep = "_")
  filename_figure = paste(filename_figure, "eps", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  p <- ggplot(species_data_out, aes(x = YEAR, y = TB, color = PID)) + 
    facet_wrap("biodiversity", nrow = 2) + 
    geom_line() +
    scale_color_discrete("Species") +
    ggtitle(paste0("Total Biomass Cell ", forest_cells$cell[i], sep = "")) +
    xlab("Date") +
    ylab("Total Biomass [kgC]") + 
    theme_bw()
  p
  
  filename_figure = paste("total_biomass", "cell", forest_cells$cell[i], sep = "_")
  filename_figure = paste(filename_figure, "png", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
  
  filename_figure = paste("total_biomass", "cell", forest_cells$cell[i], sep = "_")
  filename_figure = paste(filename_figure, "eps", sep = ".")
  filename_figure = file.path(figure_dir, filename_figure)
  ggsave(filename_figure, plot = p, device = NULL, path = NULL,
         scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
         units =  "mm")
    
}

i = 1
figure_dir = paste("test_plantFATE_out/output/test_individual_cells/", forest_cells$cell[i], "/", sep = "")
dir.create(figure_dir, showWarnings = FALSE, recursive = TRUE)

community_level_out_all <- lapply(1:nrow(forest_cells), function(i){
  results_directory = ifelse(forest_cells$new_forest[i], "output/cell", "simulation_root/default/plantFATE/cell")
  results_directory_hb = paste(results_directory, forest_cells$cell[i], "hb", sep = "_")
  results_directory_lb = paste(results_directory, forest_cells$cell[i], "lb", sep = "_")
  community_level_out_hb <- read.csv(paste(results_directory_hb, "/D_PFATE.csv", sep = ""))
  community_level_out_hb$date <- as.Date(paste(community_level_out_hb$IYEAR, community_level_out_hb$MON, community_level_out_hb$DAY, sep = "-"))
  community_level_out_hb$biodiversity <- "High"
  community_level_out_lb <- read.csv(paste(results_directory_lb, "/D_PFATE.csv", sep = ""))
  community_level_out_lb$date <- as.Date(paste(community_level_out_lb$IYEAR, community_level_out_lb$MON, community_level_out_lb$DAY, sep = "-"))
  community_level_out_lb$biodiversity <- "Low"
  community_level_out <- rbind(community_level_out_lb, community_level_out_hb)
  community_level_out$biodiversity <- factor(community_level_out$biodiversity, levels = c("High", "Low"))
  community_level_out$cell <- forest_cells$cell[i]
  community_level_out$new_forest <- forest_cells$new_forest[i]
  return(community_level_out)
}) 
community_level_out_all <- plyr::rbind.fill(community_level_out_all)

species_data_mean_out_all <- lapply(1:nrow(forest_cells), function(i){
  results_directory = ifelse(forest_cells$new_forest[i], "output/cell", "simulation_root/default/plantFATE/cell")
  results_directory_hb = paste(results_directory, forest_cells$cell[i], "hb", sep = "_")
  results_directory_lb = paste(results_directory, forest_cells$cell[i], "lb", sep = "_")
  species_data_mean_out_hb =  read.csv(paste(results_directory_hb, "/Y_mean_PFATE.csv", sep = ""))
  species_data_mean_out_hb$biodiversity <- "High"
  species_data_mean_out_lb =  read.csv(paste(results_directory_lb, "/Y_mean_PFATE.csv", sep = ""))
  species_data_mean_out_lb$biodiversity <- "Low"
  species_data_mean_out <- rbind(species_data_mean_out_lb, species_data_mean_out_hb)
  species_data_mean_out$biodiversity <- factor(species_data_mean_out$biodiversity, levels = c("High", "Low"))
  species_data_mean_out$cell <- forest_cells$cell[i]
  species_data_mean_out$new_forest <- forest_cells$new_forest[i]
  return(species_data_mean_out)
})
species_data_mean_out_all <- plyr::rbind.fill(species_data_mean_out_all)

species_data_out_all <- lapply(1:nrow(forest_cells), function(i){
  results_directory = ifelse(forest_cells$new_forest[i], "output/cell", "simulation_root/default/plantFATE/cell")
  results_directory_hb = paste(results_directory, forest_cells$cell[i], "hb", sep = "_")
  results_directory_lb = paste(results_directory, forest_cells$cell[i], "lb", sep = "_")
  species_data_out_hb = read.csv(paste(results_directory_hb, "/Y_PFATE.csv", sep = ""))
  species_data_out_hb$biodiversity <- "High"
  species_data_out_lb =  read.csv(paste(results_directory_lb, "/Y_PFATE.csv", sep = ""))
  species_data_out_lb$biodiversity <- "Low"
  species_data_out <- rbind(species_data_out_hb, species_data_out_lb)
  species_data_out$biodiversity <- factor(species_data_out$biodiversity, levels = c("High", "Low"))
  
  species_data_out$PID <- sapply(species_data_out$PID, function(spn){
    spn <- str_sub(spn, end = -3)
    return(spn)
  })
    
  species_data_out$cell <- forest_cells$cell[i]
  species_data_out$new_forest <- forest_cells$new_forest[i]
  return(species_data_out)
})

species_data_out_all <- plyr::rbind.fill(species_data_out_all)

species_data_mean_out_all_sub_hb_existing_forest <- species_data_mean_out_all %>%
  filter(biodiversity == "High" & new_forest == FALSE)

p <- ggplot(species_data_mean_out_all_sub_hb_existing_forest, aes(x = YEAR, y=LAI))+
  geom_line() +
  ggtitle(paste0("Leaf Area Index ", "Existing Forest", sep = "")) +
  facet_wrap("cell", nrow = 3) + 
  xlab("Date") +
  ylab("LAI") + 
  theme_bw()
p

filename_figure = paste("LAI", "hb", "existing_forest", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("LAI", "hb", "existing_forest", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

species_data_mean_out_all_sub_hb_new_forest <- species_data_mean_out_all %>%
  filter(biodiversity == "High" & new_forest == TRUE)

p <- ggplot(species_data_mean_out_all_sub_hb_new_forest, aes(x = YEAR, y=LAI))+
  geom_line() +
  ggtitle(paste0("Leaf Area Index ", "New Forest", " High Biodiversity", sep = "")) +
  facet_wrap("cell", nrow = 3) + 
  xlab("Date") +
  ylab("LAI") + 
  theme_bw()
p

filename_figure = paste("LAI", "hb", "new_forest", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("LAI", "hb", "new_forest", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

species_data_mean_out_all_sub_lb_new_forest <- species_data_mean_out_all %>%
  filter(biodiversity == "Low" & new_forest == TRUE)

p <- ggplot(species_data_mean_out_all_sub_lb_new_forest, aes(x = YEAR, y=LAI))+
  geom_line() +
  ggtitle(paste0("Leaf Area Index ", "New Forest", " Low Biodiversity", sep = "")) +
  facet_wrap("cell", nrow = 3) + 
  xlab("Date") +
  ylab("LAI") + 
  theme_bw()
p

filename_figure = paste("LAI", "lb", "new_forest", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("LAI", "lb", "new_forest", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")



community_level_out_all_sub_hb_existing_forest <- community_level_out_all %>%
  filter(biodiversity == "High" & new_forest ==  FALSE) %>%
  filter(date > as.Date("2044-12-31"))

p <- ggplot(community_level_out_all_sub_hb_existing_forest, aes(x = date, y=GPP))+
  geom_line() +
  ggtitle(paste0("Gross Primary Productivity ", "Existing Forest", " \nyears 2045-2050", sep = "")) +
  facet_wrap("cell", nrow=3) +
  xlab("Date") +
  ylab("GPP [kgCm-2d-1]") + 
  theme_bw()
p

filename_figure = paste("GPP", "existing_forest", "hb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("GPP", "existing_forest", "hb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

p <- ggplot(community_level_out_all_sub_hb_existing_forest, aes(x = date, y=NPP))+
  geom_line() +
  ggtitle(paste0("NPP Primary Productivity ", "Existing Forest", " \nyears 2045-2050", sep = "")) +
  facet_wrap("cell", nrow=3) +
  xlab("Date") +
  ylab("NPP [kgCm-2d-1]") + 
  theme_bw()
p

filename_figure = paste("NPP", "existing_forest", "hb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("NPP", "existing_forest", "hb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")


community_level_out_all_sub_hb_new_forest <- community_level_out_all %>%
  filter(biodiversity == "High" & new_forest == TRUE) %>%
  filter(date > as.Date("2044-12-31"))

p <- ggplot(community_level_out_all_sub_hb_new_forest, aes(x = date, y=GPP))+
  geom_line() +
  ggtitle(paste0("Gross Primary Productivity ", "New Forest", " High Biodiversity", " \nyears 2045-2050", sep = "")) +
  facet_wrap("cell", nrow=3) +
  xlab("Date") +
  ylab("GPP [kgCm-2y-1]") + 
  theme_bw()
p

filename_figure = paste("GPP", "new_forest", "hb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("GPP", "new_forest", "hb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

p <- ggplot(community_level_out_all_sub_hb_new_forest, aes(x = date, y=NPP))+
  geom_line() +
  ggtitle(paste0("Net Primary Productivity ", "New Forest", " High Biodiversity", " \nyears 2045-2050", sep = "")) +
  facet_wrap("cell", nrow =3) + 
  xlab("Date") +
  ylab("NPP [kgCm-2y-1]") + 
  theme_bw()
p

filename_figure = paste("NPP", "new_forest", "hb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("NPP", "new_forest", "hb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")


community_level_out_all_sub_lb_new_forest <- community_level_out_all %>%
  filter(biodiversity == "Low" & new_forest == TRUE) %>%
  filter(date > as.Date("2044-12-31"))

p <- ggplot(community_level_out_all_sub_lb_new_forest, aes(x = date, y=GPP))+
  geom_line() +
  ggtitle(paste0("Gross Primary Productivity ", "New Forest", " Low Biodiversity", " \nyears 2045-2050", sep = "")) +
  facet_wrap("cell", nrow=3) +
  xlab("Date") +
  ylab("GPP [kgCm-2y-1]") + 
  theme_bw()
p

filename_figure = paste("GPP", "new_forest", "lb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("GPP", "new_forest", "lb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

p <- ggplot(community_level_out_all_sub_lb_new_forest, aes(x = date, y=NPP))+
  geom_line() +
  ggtitle(paste0("Net Primary Productivity ", "New Forest", " Low Biodiversity", " \nyears 2045-2050", sep = "")) +
  facet_wrap("cell", nrow = 3) +
  xlab("Date") +
  ylab("NPP [kgCm-2y-1]") + 
  theme_bw()
p

filename_figure = paste("NPP", "new_forest", "lb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("NPP", "new_forest", "lb", "2045", "2050", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")




species_data_out_all_sub_hb_existing_forest <- species_data_out_all %>%
  filter(biodiversity == "High" & new_forest == FALSE)


p <- ggplot(species_data_out_all_sub_hb_existing_forest, aes(x = YEAR, y = TB, color = PID)) + 
  facet_wrap("biodiversity", nrow = 2) + 
  geom_line() +
  scale_color_scico_d("Species", palette="batlow") +
  ggtitle(paste0("Total Biomass ","Existing Forest", " High Biodiversity", sep = "")) +
  facet_wrap("cell", nrow = 3) + 
  xlab("Date") +
  ylab("Total Biomass [kgC]") + 
  theme_bw() + 
  theme(legend.position = "bottom")
p

filename_figure = paste("total_biomass", "existing_forest", "hb", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("total_biomass", "existing_forest", "hb", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")


species_data_out_all_sub_hb_new_forest <- species_data_out_all %>%
  filter(biodiversity == "High" & new_forest == TRUE)


p <- ggplot(species_data_out_all_sub_hb_new_forest, aes(x = YEAR, y = TB, color = PID)) + 
  facet_wrap("biodiversity", nrow = 2) + 
  geom_line() +
  scale_color_discrete("Species") +
  ggtitle(paste0("Total Biomass ","New Forest", " High Biodiversity", sep = "")) +
  facet_wrap("cell", nrow = 3) + 
  xlab("Date") +
  ylab("Total Biomass [kgC]") + 
  theme_bw() +
  theme(legend.position = "bottom")
p

filename_figure = paste("total_biomass", "new_forest", "hb", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("total_biomass", "new_forest", "hb", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")


species_data_out_all_sub_lb_new_forest <- species_data_out_all %>%
  filter(biodiversity == "Low" & new_forest == TRUE)


p <- ggplot(species_data_out_all_sub_lb_new_forest, aes(x = YEAR, y = TB, color = PID)) + 
  facet_wrap("biodiversity", nrow = 2) + 
  geom_line() +
  scale_color_discrete("Species") +
  ggtitle(paste0("Total Biomass ","New Forest", " Low Biodiversity", sep = "")) +
  facet_wrap("cell", nrow = 3) + 
  xlab("Date") +
  ylab("Total Biomass [kgC]") + 
  theme_bw() +
  theme(legend.position = "bottom")
p

filename_figure = paste("total_biomass", "new_forest", "lb", sep = "_")
filename_figure = paste(filename_figure, "png", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("total_biomass", "new_forest", "lb", sep = "_")
filename_figure = paste(filename_figure, "eps", sep = ".")
filename_figure = file.path(figure_dir, filename_figure)
ggsave(filename_figure, plot = p, device = NULL, path = NULL,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")
