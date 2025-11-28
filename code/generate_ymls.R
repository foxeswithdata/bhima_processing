library(yaml)

example_run <- yaml::read_yaml("~/my_work/cWATm/model_setups/sanctuary/model.yml")
example_run
example_run$inherits

write_yaml(data.frame(a=1:10, b=letters[1:10], c=11:20), "test.yml")

write_yaml(example_run, "test_2.yml")


afforestation_level = c(0, 0.2, 0.4, 0.6, 0.8, 1.0)
start_time = c('1990', '1991', '1992')

df_ymls = data.frame(job_id = c(1,2,3), start_time = start_time)

for(i in 1:nrow(df_ymls)){
  yml_config = list()
  yml_config$inherits = "resist_config.yml"
  yml_config$general = list(start_time = paste0(df_ymls$start_time[i], '-12-31'),
                            spinup_name = paste0("test_spinup_job_", df_ymls$job_id[i]))
  
  
  yml_filename = paste0("out/configs/", "model_job_", df_ymls$job_id[i], ".yml") 
  write_yaml(yml_config, yml_filename)
}

