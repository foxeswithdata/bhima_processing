import numpy as np
import xarray as xr
import pandas as pd
import datetime as dt
import itertools

simulations = "BAU"
simulations = "desireable_futures"

da_temp = xr.open_zarr(
            str("data/preliminary_analysis/" + simulations + "/temperature_K.zarr.zip"),
            consolidated=False
        )
da_vpd = xr.open_zarr(
            str("data/preliminary_analysis/" + simulations + "/vapour_pressure_deficit_kPa.zarr.zip"),
            consolidated = False
        )
da_ppfd = xr.open_zarr(
            str("data/preliminary_analysis/" + simulations + "/photosynthetic_photon_flux_density_W_m2.zarr.zip"),
            consolidated = False
        )
da_swp = xr.open_zarr(
            str("data/preliminary_analysis/" + simulations + "/soil_water_potential_MPa.zarr.zip"),
            consolidated=False
        )
da_nr = xr.open_zarr(
            str("data/preliminary_analysis/" + simulations + '/net_absorbed_radiation_vegetation_MJ_m2_day.zarr.zip'),
            consolidated=False
        )
da_biomass = xr.open_zarr(
            str("data/preliminary_analysis/" + simulations + '/biomass_pf.zarr.zip'),
            consolidated=False
        )
da_npp = xr.open_zarr(
            str("data/preliminary_analysis/" + simulations + '/npp_pf.zarr.zip'),
            consolidated=False
        )
da_num_ind = xr.open_zarr(
            str("data/preliminary_analysis/" + simulations + '/number_of_individuals_pf.zarr.zip'),
            consolidated=False
        )

print("grouping by")
print(da_biomass)

da_T_aggregated = da_temp.mean(dim=["x", "y"])
da_T_aggregated = da_T_aggregated["temperature_K"].to_series() - 273.15 # K -> C
da_vpd_aggregated = da_vpd.mean(dim=["x", "y"])
da_vpd_aggregated = da_vpd_aggregated["vapour_pressure_deficit_kPa"].to_series() # kPa
da_ppfd_aggregated = da_ppfd.mean(dim=["x", "y"])
da_ppfd_aggregated = da_ppfd_aggregated["photosynthetic_photon_flux_density_W_m2"].to_series() # * 0.5 # Wm-2 -> umolm-2s-1
da_swp_aggregated = da_swp.mean(dim=["x", "y"])
da_swp_aggregated = da_swp_aggregated["soil_water_potential_MPa"].to_series() * (-1)
da_nr_aggregated = da_nr.mean(dim=["x", "y"])
da_nr_aggregated = da_nr_aggregated["net_absorbed_radiation_vegetation_MJ_m2_day"].to_series()
da_biomass_aggregated = da_biomass.sum(dim=["x", "y"]) * 817398.837317795 # kgC/m2 -> kgC - assuming grid cell is 1kmx1km
da_biomass_aggregated = da_biomass_aggregated["biomass_pf"].to_series()
da_npp_aggregated = da_npp.sum(dim=["x", "y"]) * 817398.837317795 # kgC/m2 -> kgC - assuming grid cell is 1kmx1km
da_npp_aggregated = da_npp_aggregated["npp_pf"].to_series()


print(da_biomass_aggregated)
# print(da_ppfd_aggregated)
# print(da_swp_aggregated)
# print(da_nr_aggregated)
out_put = pd.DataFrame(data = da_biomass_aggregated)
out_put_npp = pd.DataFrame(data = da_npp_aggregated)

filename = str("biomass_" + simulations + ".csv")

print(out_put)
out_put.to_csv(filename, index = False)


filename = str("npp_" + simulations + ".csv")

print(out_put_npp)
out_put_npp.to_csv(filename, index = False)




da_T_aggregated = da_temp.groupby("time.year").mean(dim=["time", "x", "y"])
da_T_aggregated = da_T_aggregated["temperature_K"].to_series() - 273.15 # K -> C
da_vpd_aggregated = da_vpd.groupby("time.year").mean(dim=["time", "x", "y"])
da_vpd_aggregated = da_vpd_aggregated["vapour_pressure_deficit_kPa"].to_series() # kPa
da_ppfd_aggregated = da_ppfd.groupby("time.year").mean(dim=["time", "x", "y"])
da_ppfd_aggregated = da_ppfd_aggregated["photosynthetic_photon_flux_density_W_m2"].to_series() # * 0.5 # Wm-2 -> umolm-2s-1
da_swp_aggregated = da_swp.groupby("time.year").mean(dim=["time", "x", "y"])
da_swp_aggregated = da_swp_aggregated["soil_water_potential_MPa"].to_series() * (-1)
da_nr_aggregated = da_nr.groupby("time.year").mean(dim=["time", "x", "y"])
da_nr_aggregated = da_nr_aggregated["net_absorbed_radiation_vegetation_MJ_m2_day"].to_series()
da_biomass_aggregated = da_biomass.groupby("time.year").mean(dim=["time"]).sum(dim=["x","y"])
da_biomass_aggregated =  da_biomass_aggregated * 817398.837317795 # kgC/m2 -> kgC - assuming grid cell is 1kmx1km
da_biomass_aggregated = da_biomass_aggregated["biomass_pf"].to_series()
da_npp_aggregated = da_npp.groupby("time.year").sum(dim=["time", "x", "y"]) * 817398.837317795 # kgC/m2/day -> kgC/day - assuming grid cell is 1kmx1km
da_npp_aggregated = da_npp_aggregated["npp_pf"].to_series()


print("AGGREGATED")
print(da_biomass_aggregated)
print(type(da_biomass_aggregated))

print("END AGGREGATED")
print(da_biomass_aggregated.index)
# print(da_ppfd_aggregated)
# print(da_swp_aggregated)
# print(da_nr_aggregated)

out_put = pd.DataFrame(data = {'Time': list(da_biomass_aggregated.index),
                               'Temp': list(da_T_aggregated),
                               'VPD': list(da_vpd_aggregated),
                               "PAR" : list(da_ppfd_aggregated),
                               "PAR_max" : list(da_ppfd_aggregated * 4),
                               "SWP" : list(da_swp_aggregated),
                               "biomass" : list(da_biomass_aggregated),
                               "NPP" : list(da_npp_aggregated)})


# out_put = pd.DataFrame(data = da_biomass_aggregated)
# out_put_npp = pd.DataFrame(data = da_npp_aggregated)
print(out_put.head(10))

filename = str("all_data_" + simulations + "_preliminary_yearly.csv")

# print(out_put)
out_put.to_csv(filename)
# filename = str("npp_" + simulations + "_final.csv")
# print(out_put_npp)
# out_put_npp.to_csv(file







da_T_aggregated = da_temp.groupby("time.month").mean(dim=["time", "x", "y"])
da_T_aggregated = da_T_aggregated["temperature_K"].to_series() - 273.15 # K -> C
da_vpd_aggregated = da_vpd.groupby("time.month").mean(dim=["time", "x", "y"])
da_vpd_aggregated = da_vpd_aggregated["vapour_pressure_deficit_kPa"].to_series() # kPa
da_ppfd_aggregated = da_ppfd.groupby("time.month").mean(dim=["time", "x", "y"])
da_ppfd_aggregated = da_ppfd_aggregated["photosynthetic_photon_flux_density_W_m2"].to_series() # * 0.5 # Wm-2 -> umolm-2s-1
da_swp_aggregated = da_swp.groupby("time.month").mean(dim=["time", "x", "y"])
da_swp_aggregated = da_swp_aggregated["soil_water_potential_MPa"].to_series() * (-1)
da_nr_aggregated = da_nr.groupby("time.month").mean(dim=["time", "x", "y"])
da_nr_aggregated = da_nr_aggregated["net_absorbed_radiation_vegetation_MJ_m2_day"].to_series()
da_biomass_aggregated = da_biomass.groupby("time.month").mean(dim=["time"]).sum(dim=["x","y"])
da_biomass_aggregated =  da_biomass_aggregated * 817398.837317795 # kgC/m2 -> kgC - assuming grid cell is 1kmx1km
da_biomass_aggregated = da_biomass_aggregated["biomass_pf"].to_series()
da_npp_aggregated = da_npp.groupby("time.month").sum(dim=["time", "x", "y"]) * 817398.837317795 # kgC/m2/day -> kgC/day - assuming grid cell is 1kmx1km
da_npp_aggregated = da_npp_aggregated["npp_pf"].to_series()


print("AGGREGATED")
print(da_biomass_aggregated)
print(type(da_biomass_aggregated))

print("END AGGREGATED")
print(da_biomass_aggregated.index)
# print(da_ppfd_aggregated)
# print(da_swp_aggregated)
# print(da_nr_aggregated)

out_put = pd.DataFrame(data = {'Time': list(da_biomass_aggregated.index),
                               'Temp': list(da_T_aggregated),
                               'VPD': list(da_vpd_aggregated),
                               "PAR" : list(da_ppfd_aggregated),
                               "PAR_max" : list(da_ppfd_aggregated * 4),
                               "SWP" : list(da_swp_aggregated),
                               "biomass" : list(da_biomass_aggregated),
                               "NPP" : list(da_npp_aggregated)})


# out_put = pd.DataFrame(data = da_biomass_aggregated)
# out_put_npp = pd.DataFrame(data = da_npp_aggregated)
print(out_put.head(10))

filename = str("all_data_" + simulations + "_preliminary_monthly.csv")

# print(out_put)
out_put.to_csv(filename)
# filename = str("npp_" + simulations + "_final.csv")
# print(out_put_npp)
# out_put_npp.to_csv(file