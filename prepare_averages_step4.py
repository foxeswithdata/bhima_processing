import numpy as np
import pandas as pd
import xarray as xr
import os
import geopandas as gpd

### STEP 4 data

ghod_region = gpd.read_file("data/maps/region.gpkg")
out_folder = "out/ssp3_preproc/"

data_folder = "data/ssp3_out/"
simulations = ["GEB_step4_hb_af_00", "GEB_step4_hb_af_02", "GEB_step4_hb_af_04", "GEB_step4_hb_af_06", "GEB_step4_hb_af_08", "GEB_step4_hb_af_10",
               "GEB_step4_lb_af_00", "GEB_step4_lb_af_02", "GEB_step4_lb_af_04", "GEB_step4_lb_af_06", "GEB_step4_lb_af_08", "GEB_step4_lb_af_10",
               "GEB_step4"]
biodiversity = ["high", "low"]
afforestation = pd.array([0, 0.2, 0.4, 0.6, 0.8, 10])
afforestation_str = pd.array(["00", "02", "04", "06", "08", "10"])
outputs = ["groundwater_recharge_forest_m.zarr", "soil_moisture_forest_m.zarr", "transpiration_forest_m.zarr"]
outputs_pf = [ "groundwater_recharge_plantfate_m.zarr", "soil_moisture_plantfate_m.zarr", "transpiration_plantfate_m.zarr", "biomass_forest_plantFATE.zarr", "NPP_forest_plantFATE.zarr",]
all_outputs = outputs + outputs_pf

sim_df = pd.DataFrame(data = {'file_name': simulations,
                              'afforestation': np.concat([afforestation, afforestation, ["na"]]),
                              'afforestation_str': np.concat([afforestation_str, afforestation_str, ["na"]]),
                              'biodiversity': np.concat([np.repeat(biodiversity, 6), ["na"]]),
                              'plantFATE': np.concat([np.repeat(True, 12), [False]])})

outputs_all_df = pd.DataFrame(data = {'file_name': all_outputs,
                                  'scale': np.concat([np.repeat("forest", 3), np.repeat("plantfate", 5)]),
                                  'variable': ['groundwater_recharge_forest_m', 'soil_moisture_forest_m', 'transpiration_forest_m',
                                              'groundwater_recharge_plantfate_m', 'soil_moisture_plantfate_m', 'transpiration_plantfate_m',  'biomass_forest_plantFATE', 'NPP_forest_plantFATE']})


soil_data_filename = "data/" + "soil_layer_forest_height_m_m.zarr"
da_zarr_soil = xr.open_zarr(soil_data_filename, consolidated=False)
da_zarr_soil.rio.write_crs(ghod_region.crs, inplace=True)
da_zarr_soil = da_zarr_soil.rio.clip(
    ghod_region.geometry,
    ghod_region.crs,
    drop=True
)

da_zarr_soil = da_zarr_soil.mean(dim=["time"])


def is_monsoon(month):
    return (month >= 6) & (month <= 8)

def is_dry(month):
    return (month >= 1) & (month <= 3)

outputs = ["groundwater_recharge_forest_m.zarr"]

outputs_df = outputs_all_df.head(5)
print(outputs_df)
sim_df_sub = sim_df
print(sim_df_sub)

for index_o, row_o in outputs_df.iterrows():
    aggregated_monthly = []
    aggregated_yearly = []
    aggregated_monsoon = []
    aggregated_dry = []
    aggregated_rolling = []
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
                da_zarr = da_zarr['soil_moisture_forest_m'] / da_zarr_soil['soil_layer_forest_height_m_m']
                da_zarr.rename('soil_moisture_forest_m')
            else:
                da_zarr = da_zarr[row_o['variable']]

            filename_area = str("data/GEB_step4_test_new_forest_area_af_" +
                                row['afforestation_str'] +
                                "_lb/hydrology.soil/" +
                                row_o['scale'] +
                                "_area_m2.zarr")

            if row['afforestation'] == 'na':
                filename_area = "data/GEB_step4_test_new_forest_area_af_00_lb/hydrology.soil/forest_area_m2.zarr"

            da_zarr_area = xr.open_zarr(filename_area, consolidated=False)
            da_zarr_area.rio.write_crs(ghod_region.crs, inplace=True)
            da_zarr_area = da_zarr_area.rio.clip(
                ghod_region.geometry,
                ghod_region.crs,
                drop=True
            )

            da_zarr_area = da_zarr_area.mean(dim='time')
            total_area = float(da_zarr_area[str(row_o['scale'] + '_area_m2')].sum())
            da_zarr_normalized = (da_zarr * da_zarr_area[str(row_o['scale'] + '_area_m2')]) / total_area

            print(da_zarr_normalized)

            da_aggregated_monthly = (da_zarr_normalized.groupby(["time.month", "time.year"]).mean(dim=['time'], skipna=True)
                                     .sum(dim=["x", "y"], skipna=True)
                                     .to_dataframe(name = row_o['variable']))
            da_aggregated_monthly['afforestation'] = row['afforestation']
            da_aggregated_monthly['biodiversity'] = row['biodiversity']
            da_aggregated_monthly = da_aggregated_monthly.drop('spatial_ref', axis=1)
            da_aggregated_monthly = da_aggregated_monthly.drop('crs', axis=1)
            aggregated_monthly.append(da_aggregated_monthly)

            da_aggregated_yearly = (da_zarr_normalized.groupby("time.year").mean(dim=['time'], skipna=True)
                                    .sum(dim=["x", "y"], skipna=True)
                                    .to_dataframe(name = row_o['variable']))
            da_aggregated_yearly['afforestation'] = row['afforestation']
            da_aggregated_yearly['biodiversity'] = row['biodiversity']
            da_aggregated_yearly = da_aggregated_yearly.drop('spatial_ref', axis=1)
            da_aggregated_yearly = da_aggregated_yearly.drop('crs', axis=1)
            aggregated_yearly.append(da_aggregated_yearly)

            da_aggregated_monsoon = (da_zarr_normalized.sel(
                time=is_monsoon(da_zarr_normalized['time.month'])).groupby("time.year").mean(dim=['time'], skipna=True)
                                     .sum(dim=["x", "y"], skipna=True)
                                     .to_dataframe(name = row_o['variable']))
            da_aggregated_monsoon['afforestation'] = row['afforestation']
            da_aggregated_monsoon['biodiversity'] = row['biodiversity']
            da_aggregated_monsoon = da_aggregated_monsoon.drop('spatial_ref', axis=1)
            da_aggregated_monsoon = da_aggregated_monsoon.drop('crs', axis=1)
            aggregated_monsoon.append(da_aggregated_monsoon)

            da_aggregated_dry = (da_zarr_normalized.sel(
                time=is_dry(da_zarr_normalized['time.month'])).groupby("time.year").mean(dim=['time'], skipna=True)
                                 .sum(dim=["x", "y"], skipna=True)
                                 .to_dataframe(name = row_o['variable']))
            da_aggregated_dry['afforestation'] = row['afforestation']
            da_aggregated_dry['biodiversity'] = row['biodiversity']
            da_aggregated_dry = da_aggregated_dry.drop('spatial_ref', axis=1)
            da_aggregated_dry = da_aggregated_dry.drop('crs', axis=1)
            aggregated_dry.append(da_aggregated_dry)

            da_aggregated_rolling = da_zarr_normalized.sum(dim = ["x", "y"], skipna=True).rolling(time=14).mean(skipna=True).to_dataframe(name = row_o['variable'])
            da_aggregated_rolling['afforestation'] = row['afforestation']
            da_aggregated_rolling['biodiversity'] = row['biodiversity']
            da_aggregated_rolling = da_aggregated_rolling.drop('spatial_ref', axis=1)
            da_aggregated_rolling = da_aggregated_rolling.drop('crs', axis=1)
            aggregated_rolling.append(da_aggregated_rolling)

            da_aggregated_daily = da_zarr_normalized.sum(dim=["x", "y"], skipna=True).to_dataframe(name = row_o['variable'])
            da_aggregated_daily['biodiversity'] = row['biodiversity']
            da_aggregated_daily['afforestation'] = row['afforestation']
            da_aggregated_daily = da_aggregated_daily.drop('spatial_ref', axis=1)
            da_aggregated_daily = da_aggregated_daily.drop('crs', axis=1)
            aggregated_daily.append(da_aggregated_daily)

        else:
            print(str("skipping " + filename))

    #save csv files
    filename = str('out/ssp3_preproc/' + row_o['variable'] + "_" + row_o['scale'] + "_average_monthly.csv")
    pd.concat(aggregated_monthly).to_csv(filename, index=True)

    filename = str('out/ssp3_preproc/' + row_o['variable'] + "_" + row_o['scale'] + "_average_yearly.csv")
    pd.concat(aggregated_yearly).to_csv(filename, index=True)

    filename = str('out/ssp3_preproc/' + row_o['variable'] + "_" + row_o['scale'] +"_average_monsoon.csv")
    pd.concat(aggregated_monsoon).to_csv(filename, index=True)

    filename = str('out/ssp3_preproc/' + row_o['variable'] + "_" + row_o['scale'] + "_average_dry_season.csv")
    pd.concat(aggregated_dry).to_csv(filename, index=True)

    filename = str('out/ssp3_preproc/' + row_o['variable'] + "_" + row_o['scale'] + "_rolling_average_14_days.csv")
    pd.concat(aggregated_rolling).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable'] + "_" + row_o['scale'] + "_average_daily.csv")
    pd.concat(aggregated_daily).to_csv(filename, index=True)


### PlantFATE totals
#
# grid_area = 817398.837317795
#
# outputs_df = outputs_all_df.iloc[5:8, :]
# print(outputs_df)
#
# for index_o, row_o in outputs_df.iterrows():
#     aggregated_sum_daily = []
#     aggregated_sum_daily_rolling = []
#
#     for index, row in sim_df_sub.iterrows():
#
#         filename = str(data_folder + row['file_name'] + "/hydrology.soil/" + row_o['file_name'])
#         print(filename)
#
#         filename_area = str("data/GEB_step4_test_new_forest_area_af_" +
#                             row['afforestation_str'] +
#                             "_lb/hydrology.soil/" +
#                             row_o['scale'] +
#                             "_area_m2.zarr")
#         print(filename_area)
#
#         if os.path.exists(filename):
#             da_zarr = xr.open_zarr(filename, consolidated=False)
#             da_zarr.rio.write_crs(ghod_region.crs, inplace=True)
#             da_zarr = da_zarr.rio.clip(
#                 ghod_region.geometry,
#                 ghod_region.crs,
#                 drop=True
#             )
#
#             da_zarr_area = xr.open_zarr(filename_area, consolidated=False)
#             da_zarr_area.rio.write_crs(ghod_region.crs, inplace=True)
#             da_zarr_area = da_zarr_area.rio.clip(
#                 ghod_region.geometry,
#                 ghod_region.crs,
#                 drop=True
#             )
#             da_zarr_area = da_zarr_area.sel(time="2020-01-06")
#             print(da_zarr)
#             print(da_zarr_area)
#
#             da_zarr_normalized = da_zarr * da_zarr_area['plantfate_area_m2']
#
#             print(da_zarr_normalized)
#
#             da_zarr_aggregated_sum_daily = da_zarr_normalized.sum(
#                 dim=["x", "y"],
#                 skipna=True) # kgC/m2 -> kgC - assuming grid cell is 1kmx1km
#
#             da_zarr_aggregated_sum_daily = da_zarr_aggregated_sum_daily.to_dataframe()
#
#
#             da_zarr_aggregated_sum_daily['afforestation'] = row['afforestation']
#             da_zarr_aggregated_sum_daily['biodiversity'] = row['biodiversity']
#             print(row['afforestation'])
#             print(row['biodiversity'])
#             da_zarr_aggregated_sum_daily = da_zarr_aggregated_sum_daily.drop('spatial_ref', axis=1)
#             da_zarr_aggregated_sum_daily = da_zarr_aggregated_sum_daily.drop('crs', axis=1)
#             aggregated_sum_daily.append(da_zarr_aggregated_sum_daily)
#
#             da_zarr_aggregated_sum_daily_rolling = da_zarr_normalized.sum(
#                 dim=["x", "y"]).rolling(time=14).mean().to_dataframe() * grid_area  # kgC/m2 -> kgC - assuming grid cell is 1kmx1km
#             da_zarr_aggregated_sum_daily_rolling['afforestation'] = row['afforestation']
#             da_zarr_aggregated_sum_daily_rolling['biodiversity'] = row['biodiversity']
#             da_zarr_aggregated_sum_daily_rolling = da_zarr_aggregated_sum_daily_rolling.drop('spatial_ref', axis=1)
#             da_zarr_aggregated_sum_daily_rolling = da_zarr_aggregated_sum_daily_rolling.drop('crs', axis=1)
#             aggregated_sum_daily_rolling.append(da_zarr_aggregated_sum_daily_rolling)
#             # print(da_zarr_aggregated_sum_daily_rolling)
#
#         else:
#             print(str("skipping " + filename))
#
#     # save csv files
#     filename = str('out/ssp3_preproc/' + row_o['variable'] + "_" + row_o['scale'] + "_basin_sum_daily.csv")
#     pd.concat(aggregated_sum_daily).to_csv(filename, index=True)
#
#     filename = str('out/ssp3_preproc/' + row_o['variable'] + "_" + row_o['scale'] + "_basin_sum_daily_rolling.csv")
#     pd.concat(aggregated_sum_daily_rolling).to_csv(filename, index=True)