# looking at plantfate outputs from plantfate spinup alone (step 2)
# 14/04/2025  
# update 22/04/2025 with full model run

library(tidyverse)
library(ggpubr) #ggarrange
library(fmsb) #radar chart

#note: needed to remove the non-breaking spaces 
# cd /mnt/c/Users/maxwell/OneDrive\ -\ University\ of\ Cambridge/Documents/09_IIASA/04_Work/From_pdrive/XXXXX/
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
  theme_bw()

sp_ph <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = PH, color = PID), linewidth = 1)+
  labs(y = "Height")+
  theme_bw()

sp_ca <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = CA, color = PID), linewidth = 1)+
  labs(y = "Canopy area")+
  theme_bw()

sp_ba <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = BA, color = PID), linewidth = 1)+
  labs(y = "Basal area")+
  theme_bw()

sp_tb <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = TB, color = PID), linewidth = 1)+
  labs(y = "Biomass")+
  theme_bw()

sp_seeds <- ggplot(species_properties)+
  geom_line(aes(x = YEAR, y = SEEDS, color = PID), linewidth = 1)+
  labs(y = "Seeds")+
  theme_bw()


species_properties_plot <- ggarrange(sp_dens, sp_ph, sp_ca, sp_ba, sp_tb, sp_seeds,
          ncol = 2, nrow = 3,
          common.legend = TRUE)
# # legend = "none"
# ggsave("data/spinup/spinup_PF/plots/species_properties_plot.png",species_properties_plot,
#        width = 9.23, height = 8.06)

# ggsave("data/spinup/spinup_PF/plots/species_properties_plot_5000.png",species_properties_plot,
#        width = 9.23, height = 8.06)

##### community properties #####

com_dens <- ggplot(community_properties)+
  geom_line(aes(x = YEAR, y = DE), linewidth = 1)+
  labs(y = "Density")+
  theme_bw()

com_cl <- ggplot(community_properties)+
  geom_line(aes(x = YEAR, y = CL), linewidth = 1)+
  labs(y = "Leaf mass")+
  theme_bw()

com_cw <- ggplot(community_properties)+
  geom_line(aes(x = YEAR, y = CW), linewidth = 1)+
  labs(y = "Stem mass")+
  theme_bw()

com_ccr <- ggplot(community_properties)+
  geom_line(aes(x = YEAR, y = CCR), linewidth = 1)+
  labs(y = "Coarse root mass")+
  theme_bw()

com_fcr <- ggplot(community_properties)+
  geom_line(aes(x = YEAR, y = CFR), linewidth = 1)+
  labs(y = "Fine root mass")+
  theme_bw()

com_ca <- ggplot(community_properties)+
  geom_line(aes(x = YEAR, y = CA), linewidth = 1)+
  labs(y = "Canopy area")+
  theme_bw()

com_ba <- ggplot(community_properties)+
  geom_line(aes(x = YEAR, y = BA), linewidth = 1)+
  labs(y = "Basal area")+
  theme_bw()

com_tb <- ggplot(community_properties)+
  geom_line(aes(x = YEAR, y = TB), linewidth = 1)+
  labs(y = "Biomass")+
  theme_bw()

com_lai <- ggplot(community_properties)+
  geom_line(aes(x = YEAR, y = LAI), linewidth = 1)+
  labs(y = "LAI")+
  theme_bw()

community_properties_plot <- ggarrange(com_dens, com_cl, com_cw, com_ccr, com_fcr, com_ca, com_ba,
                                       com_tb, com_lai,
                                     ncol = 3, nrow = 3)
# 
# ggsave("data/spinup/spinup_PF/plots/community_properties_plot.png",community_properties_plot,
#        width = 7.26, height = 5.62)


##### fluxes #####

gpp <- ggplot(fluxes)+
  geom_line(aes(x = YEAR, y = GPP), linewidth = 0.5)+
  labs(y = "GPP")+
  theme_bw()

npp <- ggplot(fluxes)+
  geom_line(aes(x = YEAR, y = NPP), linewidth = 0.5)+
  labs(y = "NPP")+
  theme_bw()
# 
# rau <- ggplot(fluxes)+
#   geom_line(aes(x = YEAR, y = RAU), linewidth = 1)+
#   labs(y = "Auto.Resp (kgC/m2/yr)")+
#   theme_bw()

mort <- ggplot(fluxes)+
  geom_line(aes(x = YEAR, y = MORT), linewidth = 0.5)+
  labs(y = "Mortality")+
  theme_bw()

trans <- ggplot(fluxes)+
  geom_line(aes(x = YEAR, y = TRANS), linewidth = 0.5)+
  labs(y = "Transpiration")+
  theme_bw()

vcmax <- ggplot(fluxes)+
  geom_line(aes(x = YEAR, y = VCMAX), linewidth = 0.5)+
  labs(y = "VC max")+
  theme_bw()

swpa <- ggplot(fluxes)+
  geom_line(aes(x = YEAR, y = SWPA), linewidth = 0.5)+
  labs(y = "Soil water potential")+
  theme_bw()

fluxes_plot <- ggarrange(gpp, npp, mort, trans, vcmax, swpa,
                                       ncol = 2, nrow = 3)

# ggsave("data/spinup/spinup_PF/plots/fluxes_plot.png",fluxes_plot,
# width = 9.83, height = 7.51)



##### compare species density with radar chart #####


thesis_species0$SPECIES <- str_trim(thesis_species0$SPECIES)

thesis_species <- thesis_species0 %>% 
  filter(X == c(1:10)) %>% 
  select(SPECIES, DENSITY) %>% 
  arrange (-DENSITY) %>%
  rename(Species = SPECIES,
         Density = DENSITY)%>% 
  # mutate(Density = Density_real/10) %>% 
  mutate(Species = fct_recode(Species, 
                              "Memecylon umbellatum" = "Memycelon umbellatum",
                              "Aglaia lawii" = "Amoora lawii")) %>% 
  mutate(Data = "Thesis") 
  # select(-Density_real)


pf_species_100 <- species_properties %>% 
  filter(YEAR == -2920) %>% 
  select(PID, DE) %>% 
  arrange(-DE) %>% 
  rename(Species = PID,
         Density = DE) %>% 
  mutate(Data = "PF_100")

pf_species_500 <- species_properties %>% 
  filter(YEAR == -2520) %>% 
  select(PID, DE) %>% 
  arrange(-DE) %>% 
  rename(Species = PID,
         Density = DE)%>% 
  mutate(Data = "PF_500") 

# pf_species_100
# pf_species_500
# thesis_species

#combine the three datasets
compare_density <- rbind(thesis_species,pf_species_100, pf_species_500)

#pivot wider for radarchart
compare_density_long0 <- pivot_wider(compare_density, 
                                    names_from = Species, values_from = Density)%>%
    #if species are density NA, I force to 0 for the plot
  mutate(across(everything(), .fns = ~replace_na(.,0))) 

# remove the column with the names 
compare_density_long0 <- compare_density_long0[,-1]

#name the rows
rownames(compare_density_long0) <- c("Thesis", "PF_100", "PF_500")


# To use the fmsb package, I have to add 2 lines to the dataframe: the max and min of each variable to show on the plot!
compare_density_long <- rbind(rep(0.1,10), rep(0,10) , compare_density_long0)

## log
compare_density_long_log0 <- compare_density_long0 %>% 
  mutate_at(1:10, list(log = ~ log(.))) %>% 
  select(c(11:20))

compare_density_long_log <- rbind(rep(-1,10), rep(-11,10) , compare_density_long_log0)

# final plot
png(filename="data/spinup/spinup_PF/plots/spiderplot_log_densities.png", width = 945, height = 501)
radarchart(compare_density_long_log)
legend(1.5,1, legend=c("Original thesis values", "PF 100 year run", "PF 500 year run"), title="log(Density)", pch=1, 
       bty="n" ,lwd=3, y.intersp=1, horiz=FALSE, col=c("black","pink", "green"))
dev.off()