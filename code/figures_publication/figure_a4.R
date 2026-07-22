rm(list = ls())
library(tidyverse)
library(scico)
library(ggpubr)


## Prepare outputs for figures
Sys.setlocale("LC_ALL", "en_US.UTF-8")

figure_dir = "out/figures_publication/"
dir.create(figure_dir, showWarnings = FALSE, recursive = TRUE)

environmental_data <- read.csv(file = "out/environmental_data_processed/GEB_step4_hb_af_10/out_data_daily.csv")
environmental_data$time = as.Date(environmental_data$time)

environment_data_sub <- environmental_data %>%
  filter(time > as.Date("2045-12-31") & time <= as.Date("2046-12-31"))

p_PAR <- ggplot(environment_data_sub, aes(x = time, y=PPFD))+
  geom_line() +
  xlab("Date") +
  ylab(bquote("PAR ["*mu*"mol"*m^-2*s^-1*"]")) + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title = element_text(size = 10))

p_Temp <- ggplot(environment_data_sub, aes(x = time, y=temperature_C))+
  geom_line()+
  xlab("Date") +
  ylab(bquote("Temperature ["*degree*C*"]")) + 
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title = element_text(size = 10))

p_VPD <- ggplot(environment_data_sub, aes(x = time, y=VPD_hPa))+
  geom_line()+
  xlab("Date") +
  ylab("Vapour Pressure Deficit [hPa]") + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title = element_text(size = 10)) 

p_SWP <- ggplot(environment_data_sub, aes(x = time, y=-SWP_MPa))+
  geom_line()+
  xlab("Date") +
  ylab("Soil Water Potential [-MPa]") + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title = element_text(size = 10))


p <- ggarrange(p_Temp, p_PAR, p_VPD, p_SWP, 
               ncol = 2, nrow = 2, 
               labels = c("(a)", "(b)", "(c)", "(d)"))
p

filename_figure = "figure_a4_environment_average_basin_2046"
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = "figure_a4_environment_average_basin_2046"
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")
