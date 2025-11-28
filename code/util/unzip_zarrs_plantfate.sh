#!/bin/bash

cd hydrology.routing
unzip discharge_daily.zarr.zip 
unzip discharge_daily_m3_s.zarr.zip 

rm -f discharge_daily.zarr.zip
rm -f discharge_daily_m3_s.zarr.zip

cd ../hydrology.soil
unzip groundwater_recharge_forest_m.zarr.zip 
unzip groundwater_recharge_plantfate_m.zarr.zip 
unzip net_absorbed_radiation_vegetation_MJ_m2_day.zarr.zip 
unzip photosynthetic_photon_flux_density_W_m2.zarr.zip 
unzip soil_evaporation_forest_m.zarr.zip 
unzip soil_evaporation_plantfate_m.zarr.zip 
unzip soil_moisture_forest_m.zarr.zip 
unzip soil_moisture_plantfate_m.zarr.zip 
unzip soil_water_potential_MPa.zarr.zip 
unzip temperature_K.zarr.zip 
unzip transpiration_forest_m.zarr.zip 
unzip transpiration_plantfate_m.zarr.zip 
unzip vapour_pressure_deficit_kPa.zarr.zip 
unzip biomass_forest_plantFATE.zarr.zip 
unzip NPP_forest_plantFATE.zarr.zip 

rm -f groundwater_recharge_forest_m.zarr.zip
rm -f groundwater_recharge_plantfate_m.zarr.zip
rm -f net_absorbed_radiation_vegetation_MJ_m2_day.zarr.zip
rm -f photosynthetic_photon_flux_density_W_m2.zarr.zip
rm -f soil_evaporation_forest_m.zarr.zip
rm -f soil_evaporation_plantfate_m.zarr.zip
rm -f soil_moisture_forest_m.zarr.zip
rm -f soil_moisture_plantfate_m.zarr.zip
rm -f soil_water_potential_MPa.zarr.zip
rm -f temperature_K.zarr.zip
rm -f transpiration_forest_m.zarr.zip
rm -f transpiration_plantfate_m.zarr.zip
rm -f vapour_pressure_deficit_kPa.zarr.zip
rm -f biomass_forest_plantFATE.zarr.zip
rm -f NPP_forest_plantFATE.zarr.zip
