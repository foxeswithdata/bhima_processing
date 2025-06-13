# extrapolating co2 from monthly to daily values using help from ChatGPT
# data from https://greenhousegases.science.unimelb.edu.au/#!/view
# citation https://doi.org/10.5194/gmd-13-3571-2020
# 13/06/2025

library(tidyverse)
library(lubridate)
library(zoo)

historic <- read.csv("data/co2/historic_co2.csv")
future <- read.csv("data/co2/ssp370_future_co2.csv")


historic <-  historic %>% 
  filter((between(year, 1900, 2014)))

# Convert to proper date format
future_data <- future %>%
  mutate(date = as_date(parse_date_time(datetime, orders = "d-b-Y HMS"))) %>%
  select(date, data_mean_nh)

historic_data <- historic %>%
  mutate(date = as_date(parse_date_time(datetime, orders = "d-b-Y HMS"))) %>%
  select(date, data_mean_nh)

## merge datasets
total_data <- rbind(historic_data, future_data)


#### linear extrapolate from monthly to daily values co2 ####

# Create complete daily date sequence from min to max date
full_dates <- tibble(date = seq.Date(as_date("1900-01-01"), as_date("2500-12-31"), by = "day"))

# Join with original data and interpolate missing values
total_daily <- full_dates %>%
  left_join(total_data, by = "date") %>%
  arrange(date) %>%
  mutate(data_mean_nh = na.approx(data_mean_nh, date, rule = 2))

## validate the result
# original data
plot(total_data$date, total_data$data_mean_nh)
# extrapolated data
plot(total_daily$date, total_daily$data_mean_nh)

total_daily_export <- total_daily %>% 
  mutate(
    year = year(date),
    month = month(date),
    day = day(date)
  ) %>% 
  filter((between(year, 1975, 2500)))

write_csv(total_daily_export, "data/co2/historic_and_ssp370_future_co2_daily.csv")
