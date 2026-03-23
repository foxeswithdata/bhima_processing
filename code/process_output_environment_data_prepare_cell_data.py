import os
import numpy as np
import xarray as xr
import pandas as pd
import datetime as dt
import itertools

os.chdir("..")

afforestation = "10"
biodiversity = "lb"

df_cells = pd.read_csv(str("data/afforestation_new_" + afforestation + "_cells.csv"))
print(df_cells.head())


data_folder = str("data/ssp3_out/GEB_step4_" + biodiversity + "_af_" + afforestation + "/hydrology.soil/")

da_temp = xr.open_zarr(
            str(data_folder + "temperature_K.zarr"),
            consolidated=False
        )
da_vpd = xr.open_zarr(
            str(data_folder + "vapour_pressure_deficit_kPa.zarr"),
            consolidated = False
        )
da_ppfd = xr.open_zarr(
            str(data_folder + "photosynthetic_photon_flux_density_W_m2.zarr"),
            consolidated = False
        )
da_swp = xr.open_zarr(
            str(data_folder + "soil_water_potential_MPa.zarr"),
            consolidated=False
        )
da_nr = xr.open_zarr(
            str(data_folder + "net_absorbed_radiation_vegetation_MJ_m2_day.zarr"),
            consolidated=False
        )

for cell_id in df_cells.index:
    if cell_id > 32:
        cell_num = df_cells.cell[cell_id]
        x_val = df_cells.x[cell_id]
        y_val = df_cells.y[cell_id]

        print(cell_num)
        print(x_val)
        print(y_val)

        da_T_aggregated = da_temp.sel(x=x_val, y=y_val, method='nearest')
        da_T_aggregated = da_T_aggregated["temperature_K"].to_series() - 273.15
        da_vpd_aggregated = da_vpd.sel(x=x_val, y=y_val, method='nearest')
        da_vpd_aggregated = da_vpd_aggregated["vapour_pressure_deficit_kPa"].to_series() * 10  # kPa -> hPa
        da_ppfd_aggregated = da_ppfd.sel(x=x_val, y=y_val, method='nearest')
        da_ppfd_aggregated = da_ppfd_aggregated[
            "photosynthetic_photon_flux_density_W_m2"].to_series()  # * 0.5 # Wm-2 -> umolm-2s-1
        da_swp_aggregated = da_swp.sel(x=x_val, y=y_val, method='nearest')
        da_swp_aggregated = da_swp_aggregated["soil_water_potential_MPa"].to_series() * (-1)
        da_nr_aggregated = da_nr.sel(x=x_val, y=y_val, method='nearest')
        da_nr_aggregated = da_nr_aggregated["net_absorbed_radiation_vegetation_MJ_m2_day"].to_series()


        out_put = pd.DataFrame(data = {'Year': da_T_aggregated.index,
                                       'Date': da_T_aggregated.index,
                                       'Decimal_year': range(da_T_aggregated.size),
                                       'Temp': list(da_T_aggregated),
                                       'VPD': list(da_vpd_aggregated),
                                       "PAR" : list(da_ppfd_aggregated),
                                       "PAR_max" : list(da_ppfd_aggregated * 4),
                                       "SWP" : list(da_swp_aggregated)})
        #
        # print(out_put.head())
        folder_out = str("test_plantFATE_out/data/" + "GEB_step4_" + biodiversity + "_af_" + afforestation + "/")

        if not os.path.exists(folder_out):
            os.makedirs(folder_out)

        filename = str(folder_out + "env_data_cell_" + str(cell_num) + ".csv")
        print(filename)
        out_put.to_csv(filename, index = False)