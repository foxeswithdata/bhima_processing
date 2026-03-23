rm(list = ls())

file_list <- list.files("data", "*slurm*", full.names = TRUE)
afforestation <- c("00", "02", "04", "06", "08", "10")

for(i in 2:length(file_list)){
  slurm_data <- readLines(file_list[i])
  
  j = 1
  while(slurm_data[j] != "Cell New"){
    j = j+1
  }
  
  cells = c()
  xs = c()
  ys = c()
  
  
  while(slurm_data[j] == "Cell New"){
    j = j+1
    cells = c(cells, as.numeric(slurm_data[j]))
    j = j+2
    latlong = slurm_data[j]
    latlong = unlist(stringr::str_extract_all(latlong, "[:digit:]+\\.[:digit:]+"))
    xs = c(xs, as.numeric(latlong[1]))
    ys = c(ys, as.numeric(latlong[2]))
    j = j+1
  }
  
  cell_list <- data.frame(cell = cells,
             x = xs,
             y = ys)

  filename = paste0("data/afforestation_new_", afforestation[i], "_cells.csv", sep = "")
  write.csv(cell_list, filename, row.names = FALSE)
  
}
