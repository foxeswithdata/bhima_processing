import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import xarray as xr
import os
import geopandas as gpd


### STEP 3 data

ghod_region = gpd.read_file("data/maps/region.gpkg")


data_folder = "data/ssp3_out/"
simulations = ["GEB_step3_default_spinup", "GEB_step3_plantfate_hb_spinup", "GEB_step3_plantfate_lb_spinup"]
biodiversity = ["na", "high", "low"]
sim_df_step3 = pd.DataFrame(data = {'file_name': simulations,
                              'biodiversity': biodiversity,
                              'plantFATE': [False, True, True]})

print(sim_df_step3)

### STEP 4 data

data_folder = "data/ssp3_out/"
out_folder = 'out/ssp3_preproc/spinup/'

outputs = ["groundwater_recharge_forest_m.zarr", "soil_moisture_forest_m.zarr", "transpiration_forest_m.zarr"]
outputs_pf = [ "groundwater_recharge_plantfate_m.zarr", "soil_moisture_plantfate_m.zarr", "transpiration_plantfate_m.zarr", "biomass_forest_plantFATE.zarr", "NPP_forest_plantFATE.zarr",]
all_outputs = outputs + outputs_pf

outputs_all_df = pd.DataFrame(data = {'file_name': all_outputs,
                                  'scale': np.concat([np.repeat("forest", 3), np.repeat("plantfate", 5)]),
                                  'variable': ['groundwater_recharge', 'soil_moisture', 'transpiration',
                                              'groundwater_recharge', 'soil_moisture', 'transpiration',  'biomass', 'NPP']})

def is_monsoon(month):
    return (month >= 6) & (month <= 8)

def is_dry(month):
    return (month >= 1) & (month <= 3)


outputs = ["groundwater_recharge_forest_m.zarr"]
outputs_df = outputs_all_df.iloc[0:8, :]

sim_df_sub = sim_df_step3

for index_o, row_o in outputs_df.iterrows():
    aggregated_monthly = []
    aggregated_yearly = []
    aggregated_monsoon = []
    aggregated_dry = []
    aggregated_rolling = []

    for index, row in sim_df_sub.iterrows():
        filename = str(data_folder + row['file_name'] + "/hydrology.soil/" + row_o['file_name'] )
        if os.path.exists(filename):
            da_zarr = xr.open_zarr(filename, consolidated=False)
            da_zarr.rio.write_crs(ghod_region.crs, inplace=True)
            da_zarr = da_zarr.rio.clip(
                ghod_region.geometry,
                ghod_region.crs,
                drop=True
            )
            da_aggregated_monthly = da_zarr.groupby(["time.month", "time.year"]).mean(dim=["time", "x", "y"]).to_dataframe()
            da_aggregated_monthly['biodiversity'] = row['biodiversity']
            aggregated_monthly.append(da_aggregated_monthly)

            da_aggregated_yearly = da_zarr.groupby("time.year").mean(dim=["time", "x", "y"]).to_dataframe()
            da_aggregated_yearly['biodiversity'] = row['biodiversity']
            aggregated_yearly.append(da_aggregated_yearly)

            da_aggregated_monsoon = da_zarr.sel(
                time=is_monsoon(da_zarr['time.month'])).groupby("time.year").mean(dim=["time", "x", "y"]).to_dataframe()
            da_aggregated_monsoon['biodiversity'] = row['biodiversity']
            aggregated_monsoon.append(da_aggregated_monsoon)

            da_aggregated_dry = da_zarr.sel(
                time=is_dry(da_zarr['time.month'])).groupby("time.year").mean(dim=["time", "x", "y"]).to_dataframe()
            da_aggregated_dry['biodiversity'] = row['biodiversity']
            aggregated_dry.append(da_aggregated_dry)

            da_aggregated_rolling = da_zarr.mean(dim = ["x", "y"]).rolling(time=14).mean().to_dataframe()
            da_aggregated_rolling['biodiversity'] = row['biodiversity']
            aggregated_rolling.append(da_aggregated_rolling)

        else:
            print(str("skipping " + filename))

    #save csv files
    filename = str(out_folder + row_o['variable'] + "_" + row_o['scale'] + "_average_monthly.csv")
    pd.concat(aggregated_monthly).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable'] + "_" + row_o['scale'] + "_average_yearly.csv")
    pd.concat(aggregated_yearly).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable'] + "_" + row_o['scale'] +"_average_monsoon.csv")
    pd.concat(aggregated_monsoon).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable'] + "_" + row_o['scale'] + "_average_dry_season.csv")
    pd.concat(aggregated_dry).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable'] + "_" + row_o['scale'] + "_rolling_average_14_days.csv")
    pd.concat(aggregated_rolling).to_csv(filename, index=True)



### PlantFATE totals

grid_area = 817398.837317795

outputs_df = outputs_all_df.iloc[5:8, :]
print(outputs_df)

for index_o, row_o in outputs_df.iterrows():
    aggregated_sum_daily = []
    aggregated_sum_daily_rolling = []

    for index, row in sim_df_sub.iterrows():

        filename = str(data_folder + row['file_name'] + "/hydrology.soil/" + row_o['file_name'])
        if os.path.exists(filename):
            da_zarr = xr.open_zarr(filename, consolidated=False)
            da_zarr.rio.write_crs(ghod_region.crs, inplace=True)
            da_zarr = da_zarr.rio.clip(
                ghod_region.geometry,
                ghod_region.crs,
                drop=True
            )

            da_zarr_aggregated_sum_daily = da_zarr.sum(
                dim=["x", "y"]) * grid_area  # kgC/m2 -> kgC - assuming grid cell is 1kmx1km
            da_zarr_aggregated_sum_daily = da_zarr_aggregated_sum_daily.to_dataframe()
            da_zarr_aggregated_sum_daily['biodiversity'] = row['biodiversity']
            aggregated_sum_daily.append(da_zarr_aggregated_sum_daily)

            da_zarr_aggregated_sum_daily_rolling = da_zarr.sum(
                dim=["x", "y"]).rolling(time=14).mean().to_dataframe() * grid_area  # kgC/m2 -> kgC - assuming grid cell is 1kmx1km
            da_zarr_aggregated_sum_daily_rolling['biodiversity'] = row['biodiversity']
            aggregated_sum_daily_rolling.append(da_zarr_aggregated_sum_daily_rolling)

        else:
            print(str("skipping " + filename))

    # save csv files
    print(aggregated_sum_daily)
    filename = str(out_folder + row_o['variable'] + "_" + row_o['scale'] + "_basin_sum_daily.csv")
    pd.concat(aggregated_sum_daily).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable'] + "_" + row_o['scale'] + "_basin_sum_daily_rolling.csv")
    pd.concat(aggregated_sum_daily_rolling).to_csv(filename, index=True)