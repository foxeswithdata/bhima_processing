#!/bin/bash

cd hydrology.routing
zip -r discharge_daily.zarr.zip discharge_daily.zarr/
zip -r discharge_daily_m3_s.zarr.zip discharge_daily_m3_s.zarr/

rm -rf discharge_daily.zarr/
rm -rf discharge_daily_m3_s.zarr/

cd ../hydrology.soil
zip -r groundwater_recharge_forest_m.zarr.zip groundwater_recharge_forest_m.zarr/
zip -r net_absorbed_radiation_vegetation_MJ_m2_day.zarr.zip net_absorbed_radiation_vegetation_MJ_m2_day.zarr/
zip -r photosynthetic_photon_flux_density_W_m2.zarr.zip photosynthetic_photon_flux_density_W_m2.zarr/
zip -r soil_evaporation_forest_m.zarr.zip soil_evaporation_forest_m.zarr/
zip -r soil_moisture_forest_m.zarr.zip soil_moisture_forest_m.zarr/
zip -r soil_water_potential_MPa.zarr.zip soil_water_potential_MPa.zarr/
zip -r temperature_K.zarr.zip temperature_K.zarr/
zip -r transpiration_forest_m.zarr.zip transpiration_forest_m.zarr/
zip -r vapour_pressure_deficit_kPa.zarr.zip vapour_pressure_deficit_kPa.zarr/

rm -rf groundwater_recharge_forest_m.zarr/
rm -rf net_absorbed_radiation_vegetation_MJ_m2_day.zarr/
rm -rf photosynthetic_photon_flux_density_W_m2.zarr/
rm -rf soil_evaporation_forest_m.zarr/
rm -rf soil_moisture_forest_m.zarr/
rm -rf soil_water_potential_MPa.zarr/
rm -rf temperature_K.zarr/
rm -rf transpiration_forest_m.zarr/
rm -rf vapour_pressure_deficit_kPa.zarr
