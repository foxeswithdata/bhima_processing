import numpy as np
import xarray as xr
import pandas as pd
import datetime as dt
import itertools

da_temp = xr.open_zarr(
            "data/prepare_plantfate_spinup/temperature_K.zarr",
            consolidated=False
        )
da_vpd = xr.open_zarr(
            "data/prepare_plantfate_spinup/vapour_pressure_deficit_kPa.zarr",
            consolidated = False
        )
da_ppfd = xr.open_zarr(
            "data/prepare_plantfate_spinup/photosynthetic_photon_flux_density_W_m2.zarr",
            consolidated = False
        )
da_swp = xr.open_zarr(
            "data/prepare_plantfate_spinup/soil_water_potential_MPa.zarr",
            consolidated=False
        )
da_nr = xr.open_zarr(
            'data/prepare_plantfate_spinup/net_absorbed_radiation_vegetation_MJ_m2_day.zarr',
            consolidated=False
        )

print("grouping by")

da_T_aggregated = da_temp.groupby("time.month").mean(dim=["time", "x", "y"])
da_T_aggregated = da_T_aggregated["temperature_K"].to_series() - 273.15 # K -> C
da_vpd_aggregated = da_vpd.groupby("time.month").mean(dim=["time", "x", "y"])
da_vpd_aggregated = da_vpd_aggregated["vapour_pressure_deficit_kPa"].to_series() * 10 # kPa -> hPa
da_ppfd_aggregated = da_ppfd.groupby("time.month").mean(dim=["time", "x", "y"])
da_ppfd_aggregated = da_ppfd_aggregated["photosynthetic_photon_flux_density_W_m2"].to_series() # * 0.5 # Wm-2 -> umolm-2s-1
da_swp_aggregated = da_swp.groupby("time.month").mean(dim=["time", "x", "y"])
da_swp_aggregated = da_swp_aggregated["soil_water_potential_MPa"].to_series() * (-1)
da_nr_aggregated = da_nr.groupby("time.month").mean(dim=["time", "x", "y"])
da_nr_aggregated = da_nr_aggregated["net_absorbed_radiation_vegetation_MJ_m2_day"].to_series()

print(da_vpd_aggregated)
print(da_ppfd_aggregated)
print(da_swp_aggregated)
print(da_nr_aggregated)

# Year, Month, Decimal_year, Temp (deg C), VPD (hPa), PAR (umol m-2 s-1), PAR_max (umol m-2 s-1), SWP (-MPa, i.e., absolute value), further columns are ignored

# num_years = 5000
#
#
# # print(list(range(1,13)) * num_years)
# # print(list(da_T_aggregated) * num_years)
#
# yr_list = list(range(1980-num_years, 1980))
# yrs = [ele for ele in yr_list for i in range(12)]
# # print(yr_list)
# # print(yrs)
# out_put = pd.DataFrame(data = {'Year': yrs,
#                                'Month': list(range(1,13)) * num_years,
#                                'Decimal_year': np.linspace(start=(1979 - num_years + 1),stop=1979.91666666667,num = 12 * num_years),
#                                'Temp': list(da_T_aggregated) * num_years,
#                                'VPD': list(da_vpd_aggregated) * num_years,
#                                "PAR" : list(da_ppfd_aggregated) * num_years,
#                                "PAR_max" : list(da_ppfd_aggregated * 4) * num_years,
#                                "SWP" : list(da_swp_aggregated) * num_years})
#
# print(out_put)
# out_put.to_csv("out_data_5000.csv", index = False)