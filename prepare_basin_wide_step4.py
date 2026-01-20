import numpy as np
import pandas as pd
import xarray as xr
import os
import geopandas as gpd

### STEP 4 data

ghod_region = gpd.read_file("data/maps/region.gpkg")
out_folder = "out/ssp3_preproc/not_averaged/"

data_folder = "data/ssp3_out/"
simulations = ["GEB_step4_hb_af_00", "GEB_step4_lb_af_00", "GEB_step4"]
biodiversity = ["high", "low"]
afforestation = pd.array([0])
outputs = ["groundwater_recharge_forest_m.zarr", "soil_moisture_forest_m.zarr", "transpiration_forest_m.zarr"]
outputs_pf = [ "groundwater_recharge_plantfate_m.zarr", "soil_moisture_plantfate_m.zarr", "transpiration_plantfate_m.zarr", "biomass_forest_plantFATE.zarr", "NPP_forest_plantFATE.zarr",]
all_outputs = outputs + outputs_pf

soil_data_filename = "data/" + "soil_layer_height.zarr"
da_zarr_soil = xr.open_zarr(soil_data_filename, consolidated=False)
da_zarr_soil.rio.write_crs(ghod_region.crs, inplace=True)
da_zarr_soil = da_zarr_soil.rio.clip(
    ghod_region.geometry,
    ghod_region.crs,
    drop=True
)

sim_df = pd.DataFrame(data = {'file_name': simulations,
                              'afforestation': np.concat([afforestation, afforestation,  ["na"]]),
                              'biodiversity': np.concat([biodiversity, ["na"]]),
                              'plantFATE': np.concat([np.repeat(True, 2), [False]])})

outputs_all_df = pd.DataFrame(data = {'file_name': outputs,
                                  'scale': np.concat([np.repeat("forest", 3)]),
                                  'variable': ['groundwater_recharge', 'soil_moisture', 'transpiration']})

def is_monsoon(month):
    return (month >= 6) & (month <= 8)

def is_dry(month):
    return (month >= 1) & (month <= 3)

def is_later(year):
    return year >= 2031

outputs = ["groundwater_recharge_forest_m.zarr"]
outputs_df = outputs_all_df.iloc[1:2, :]

sim_df_sub = sim_df

for index_o, row_o in outputs_df.iterrows():
    aggregated_daily = []

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

            if row_o['variable'] == "soil_moisture":
                da_zarr = da_zarr / da_zarr_soil

            print('converted soil')

            print(da_zarr)

            da_zarr = da_zarr.sel(
                time=is_later(da_zarr['time.year']))

            print('filtered time')

            print(da_zarr)

            da_aggregated_daily = da_zarr.to_dataframe()

            print('converted to dataframe')

            if isinstance(da_aggregated_daily.index, pd.MultiIndex):
                da_aggregated_daily = da_aggregated_daily.reorder_levels(['time', 'y', 'x'])

            print('converted index')




            da_aggregated_daily['biodiversity'] = row['biodiversity']
            da_aggregated_daily = da_aggregated_daily.drop('spatial_ref', axis=1)
            da_aggregated_daily = da_aggregated_daily.drop('crs', axis=1)
            da_aggregated_daily = da_aggregated_daily.dropna(axis=0)
            # aggregated_daily.append(da_aggregated_daily)
            filename = str(out_folder + row['biodiversity'] + row_o['variable'] + "_" + row_o['scale'] + "_daily.csv")
            da_aggregated_daily.to_csv(filename, index=True)
        else:
            print(str("skipping " + filename))

    #save csv files
    #
    # filename = str(out_folder + row_o['variable'] + "_" + row_o['scale'] + "_daily.csv")
    # # column_order = ["x", "y", "time", aggregated_daily[0].columns[0], 'biodiversity']
    # aggregated_daily = pd.concat(aggregated_daily)
    # print(aggregated_daily.head())
    # aggregated_daily.to_csv(filename, index=True)
