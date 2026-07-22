# looking at plantfate outputs from plantfate spinup alone (step 2)
# 14/04/2025  
# update 22/04/2025 with full model run
rm(list = ls())
library(tidyverse)
library(ggpubr) #ggarrange
library(fmsb) #radar chart
library(scico)

# palette_colours[7] = "#222222"
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# Tableau "Color Blind 10" palette — colorblind-safe, 10 categorical values
palette_colours <- c(
  "#006BA4", "#FF800E", "#ABABAB", "#595959", "#5F9ED1",
  "#C85200", "#898989", "#A2C8EC", "#FFBC79", "#CFCFCF"
)
# Seaborn "colorblind" palette — colorblind-safe, 10 categorical values
palette_colours <- c(
  "#0173B2", "#DE8F05", "#029E73", "#D55E00", "#CC78BC",
  "#CA9161", "#FBAFE4", "#949494", "#ECE133", "#56B4E9"
)

species <- c("Dimorphocalyx lawianus", "Memecylon umbellatum", "Mangifera indica",
             "Olea dioica", "Syzygium cumini", "Litsea stocksii",
             "Lepisanthes tetraphylla", "Garcinia talbotii",
             "Syzygium gardneri", "Aglaia lawii")

palette_colours <- setNames(cb10, species)


figure_dir = "out/figures_publication//"
dir.create(figure_dir, showWarnings = FALSE, recursive = TRUE)

#note: needed to remove the non-breaking spaces 
# cd PATH_TO_PROJECT_ROOT
# sed 's/\xa0/ /g' Y_PFATE.csv > Y_PFATE_repl.csv
community_properties_full <- read.csv("data/spinup/spinup_PF/Y_mean_PFATE.csv")
species_properties_full <- read.csv("data/spinup/spinup_PF/Y_PFATE_repl.csv") 
fluxes_full <- read.csv("data/spinup/spinup_PF/D_PFATE.csv") 
thesis_species0 <- read.csv("data/spinup/spinup_PF/species_thesis.csv")

#### subsetting for the first 500 years ####

species_properties_full$PID <- str_trim(species_properties_full$PID)
# filtering for the first 500 years
# and only the original 10 species (not the random invasions)
species_properties <- species_properties_full %>% 
  filter((between(YEAR, -3019.96, -2520))) %>%
  filter(PID == "Aglaia lawii" | PID == "Dimorphocalyx lawianus" | PID == "Garcinia talbotii" |
           PID == "Lepisanthes tetraphylla" | PID == "Litsea stocksii" | PID == "Mangifera indica" |
           PID == "Memecylon umbellatum" | PID == "Olea dioica" |
           PID == "Syzygium cumini" | PID == "Syzygium gardneri") %>%
  droplevels()

community_properties <- community_properties_full%>% 
  filter((between(YEAR, -3019.96, -2520)))

fluxes <- fluxes_full %>% 
  filter((between(YEAR, -3019.96, -2520)))
##### species properties #### 
sp_dens <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = DE, color = PID), linewidth = 1)+
  labs(y = "Density")+
  scale_color_manual("", values = palette_colours) +
  theme_bw()

sp_ph <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = PH, color = PID), linewidth = 1)+
  labs(y = "Height")+
  scale_color_manual("", values = palette_colours) +
  theme_bw()

sp_ca <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = CA, color = PID), linewidth = 1)+
  labs(y = "Canopy area")+
  scale_color_manual("", values = palette_colours) +
  theme_bw()

sp_ba <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = BA, color = PID), linewidth = 1)+
  labs(y = "Basal area")+
  scale_color_manual("", values = palette_colours) +
  theme_bw()

sp_tb <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = TB, color = PID), linewidth = 1)+
  labs(y = "Biomass")+
  scale_color_manual("", values = palette_colours) +
  theme_bw()

sp_seeds <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = SEEDS, color = PID), linewidth = 1)+
  labs(y = "Seeds")+
  scale_color_manual("", values = palette_colours) +
  theme_bw()


species_properties_plot <- ggarrange(sp_dens, sp_ph, sp_ca, sp_ba, sp_tb, sp_seeds,
                                     ncol = 2, nrow = 3,
                                     common.legend = TRUE)
species_properties_plot

filename_figure = paste("figure_a3_species_properties_step2")
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = species_properties_plot, device = NULL, path = figure_dir,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = paste("figure_a3_species_properties_step2")
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = species_properties_plot, device = NULL, path = figure_dir,
       scale = 1, width = 240, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")
# # legend = "none"
# ggsave("data/spinup/spinup_PF/plots/species_properties_plot.png",species_properties_plot,
#        width = 9.23, height = 8.06)

# ggsave("data/spinup/spinup_PF/plots/species_properties_plot_5000.png",species_properties_plot,
#        width = 9.23, height = 8.06)
