rm(list = ls())

library(tidyverse)
library(ggpubr)

figure_dir = "out/figures_publication/"

density <- read.csv("data/sunny_2020_thesis_data/appendix3_relative_density.csv")
head(density)

# For some reason this does not actually sum up to one so fixing
density$Closed <- density$Closed /sum(density$Closed, na.rm = TRUE) 
density$Open <- density$Open /sum(density$Open, na.rm = TRUE)
density$Edge <- density$Edge /sum(density$Edge, na.rm = TRUE)

cover <- read.csv("data/sunny_2020_thesis_data/appendix4_relative_dominance.csv")
head(cover)

cover$Closed <- cover$Closed /sum(cover$Closed, na.rm = TRUE)
cover$Open <- cover$Open /sum(cover$Open, na.rm = TRUE)
cover$Edge <- cover$Edge /sum(cover$Edge, na.rm = TRUE)

density_sub <- density %>%
  select(Species, Closed) %>%
  filter(Closed >= 0.009 & !stringr::str_starts(Species, "Unknown")) %>%
  arrange(desc(Closed))
  

cover_sub <- cover %>%
  select(Species, Closed) %>%
  filter(Closed >= 0.009 & !stringr::str_starts(Species, "Unknown")) %>%
  arrange(desc(Closed))

density_cover_sub <- dplyr::full_join(density_sub, cover_sub, by = "Species", suffix = c(".density", ".cover"), ) %>%
  pivot_longer(cols = c("Closed.density", "Closed.cover"), names_to = "name", values_to = "Closed_Forest")

density_cover_sub$Species <- factor(density_cover_sub$Species, levels=unique(density_cover_sub$Species))
density_cover_sub$name[density_cover_sub$name == "Closed.cover"] <- "Cover"
density_cover_sub$name[density_cover_sub$name == "Closed.density"] <- "Density"

p <- ggplot(density_cover_sub, aes(x = Species, y = Closed_Forest, shape = name, color = name)) +
  geom_point(stat = "identity") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab("Species") +
  scale_y_log10("Relative Value (Closed Forest)") + 
  scale_color_discrete("") + 
  scale_shape_discrete("")
p

filename_figure ="figure_a2_relative_cover_density_sunny_2020"
filename_figure = paste(filename_figure, "png", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

filename_figure = "figure_a2_relative_cover_density_sunny_2020"
filename_figure = paste(filename_figure, "eps", sep = ".")
ggsave(filename_figure, plot = p, device = NULL, path = figure_dir,
       scale = 1, width = 190, height = 138, dpi = 300, limitsize = TRUE,
       units =  "mm")

