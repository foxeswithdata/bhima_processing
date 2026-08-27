import numpy as np
import pandas as pd
import xarray as xr
import os
import geopandas as gpd

### STEP 4 data

ghod_region = gpd.read_file("data/maps/region.gpkg")
out_folder = "out/ssp3/spatial_preprocessing/"

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
                                  'variable_name': ['groundwater_recharge', 'soil_moisture', 'transpiration',
                                              'groundwater_recharge', 'soil_moisture', 'transpiration',  'biomass', 'NPP'],
                                  'variable_zarr': ['groundwater_recharge_forest_m', 'soil_moisture_forest_m', 'transpiration_forest_m',
                                              'groundwater_recharge_plantfate_m', 'soil_moisture_plantfate_m', 'transpiration_plantfate_m',  'biomass_forest_plantFATE', 'NPP_forest_plantFATE']})


soil_data_filename = "data/" + "soil_layer_forest_height_m.zarr"
da_zarr_soil = xr.open_zarr(soil_data_filename, consolidated=False)
da_zarr_soil.rio.write_crs(ghod_region.crs, inplace=True)
da_zarr_soil = da_zarr_soil.rio.clip(
    ghod_region.geometry,
    ghod_region.crs,
    drop=True
)

da_zarr_soil = da_zarr_soil.mean(dim=["time"])

sim_df_sub = sim_df
print(sim_df_sub)

### PlantFATE totals

outputs_df = outputs_all_df.iloc[5:8, :]
print(outputs_df)

for index_o, row_o in outputs_df.iterrows():
    aggregated_sum_daily = []
    aggregated_sum_daily_rolling = []
    aggregated_sum_monthly = []
    aggregated_sum_yearly = []

    for index, row in sim_df_sub.iterrows():

        filename = str(data_folder + row['file_name'] + "/hydrology.soil/" + row_o['file_name'])
        print(filename)

        filename_area = str("data/GEB_step4_test_new_forest_area_af_" +
                            row['afforestation_str'] +
                            "_lb/hydrology.soil/" +
                            row_o['scale'] +
                            "_area_m2.zarr")
        print(filename_area)

        if os.path.exists(filename):
            # --- load the per-m2 variable of interest ---
            da_zarr = xr.open_zarr(filename, consolidated=False)
            da_zarr.rio.write_crs(ghod_region.crs, inplace=True)
            da_zarr = da_zarr.rio.clip(
                ghod_region.geometry,
                ghod_region.crs,
                drop=True
            )

            # --- load the actual per-cell area (m2) for this scale/scenario ---
            da_zarr_area = xr.open_zarr(filename_area, consolidated=False)
            da_zarr_area.rio.write_crs(ghod_region.crs, inplace=True)
            da_zarr_area = da_zarr_area.rio.clip(
                ghod_region.geometry,
                ghod_region.crs,
                drop=True
            )

            # Area is constant across the entire simuilation so taking a selection of the area to remove the time dimension
            da_zarr_area = da_zarr_area.sel(time="2020-01-06")

            # Convert density (per m2) -> absolute quantity per cell, using the
            # REAL variable area for this cell (not a fixed grid-cell assumption).
            # kgC/m2 * m2 = kgC
            area_var = str(row_o['scale']) + '_area_m2'  # match naming used when the area file was built
            da_zarr_normalized = da_zarr * da_zarr_area[area_var]

            print(da_zarr_normalized)

            # ---------------- DAILY ----------------
            # sum across space -> total kgC per day for the basin
            da_zarr_aggregated_sum_daily = da_zarr_normalized.sum(
                dim=["x", "y"],
                skipna=True
            ).to_dataframe()

            da_zarr_aggregated_sum_daily['afforestation'] = row['afforestation']
            da_zarr_aggregated_sum_daily['biodiversity'] = row['biodiversity']
            da_zarr_aggregated_sum_daily = da_zarr_aggregated_sum_daily.drop('spatial_ref', axis=1)
            da_zarr_aggregated_sum_daily = da_zarr_aggregated_sum_daily.drop('crs', axis=1)
            aggregated_sum_daily.append(da_zarr_aggregated_sum_daily)

            # ---------------- DAILY, 14-DAY ROLLING MEAN ----------------
            # NOTE: da_zarr_normalized is already area-weighted above, so we do NOT
            # multiply by grid_area again here — that would double-count the area.
            da_zarr_aggregated_sum_daily_rolling = da_zarr_normalized.sum(
                dim=["x", "y"], skipna=True
            ).rolling(time=14).mean().to_dataframe()

            da_zarr_aggregated_sum_daily_rolling['afforestation'] = row['afforestation']
            da_zarr_aggregated_sum_daily_rolling['biodiversity'] = row['biodiversity']
            da_zarr_aggregated_sum_daily_rolling = da_zarr_aggregated_sum_daily_rolling.drop('spatial_ref', axis=1)
            da_zarr_aggregated_sum_daily_rolling = da_zarr_aggregated_sum_daily_rolling.drop('crs', axis=1)
            aggregated_sum_daily_rolling.append(da_zarr_aggregated_sum_daily_rolling)

            # ---------------- MONTHLY ----------------
            # sum daily totals within each year-month, across the basin
            if row_o['variable_name'] == 'biomass':
                da_zarr_aggregated_sum_monthly = (
                    da_zarr_normalized
                    .sum(dim=["x", "y"], skipna=True)
                    .groupby(["time.year", "time.month"])
                    .mean(dim="time", skipna=True)
                    .to_dataframe()
                )
            else :
                da_zarr_aggregated_sum_monthly = (
                    da_zarr_normalized
                    .sum(dim=["x", "y"], skipna=True)
                    .groupby(["time.year", "time.month"])
                    .sum(dim="time", skipna=True)
                    .to_dataframe()
                )
            da_zarr_aggregated_sum_monthly['afforestation'] = row['afforestation']
            da_zarr_aggregated_sum_monthly['biodiversity'] = row['biodiversity']
            da_zarr_aggregated_sum_monthly = da_zarr_aggregated_sum_monthly.drop('spatial_ref', axis=1)
            da_zarr_aggregated_sum_monthly = da_zarr_aggregated_sum_monthly.drop('crs', axis=1)
            aggregated_sum_monthly.append(da_zarr_aggregated_sum_monthly)

            # ---------------- YEARLY ----------------
            if row_o['variable_name'] == 'biomass':
                da_zarr_aggregated_sum_yearly = (
                    da_zarr_normalized
                    .sum(dim=["x", "y"], skipna=True)
                    .groupby("time.year")
                    .mean(dim="time", skipna=True)
                    .to_dataframe()
                )
            else:
                da_zarr_aggregated_sum_yearly = (
                    da_zarr_normalized
                    .sum(dim=["x", "y"], skipna=True)
                    .groupby("time.year")
                    .sum(dim="time", skipna=True)
                    .to_dataframe()
                )
            da_zarr_aggregated_sum_yearly['afforestation'] = row['afforestation']
            da_zarr_aggregated_sum_yearly['biodiversity'] = row['biodiversity']
            da_zarr_aggregated_sum_yearly = da_zarr_aggregated_sum_yearly.drop('spatial_ref', axis=1)
            da_zarr_aggregated_sum_yearly = da_zarr_aggregated_sum_yearly.drop('crs', axis=1)
            aggregated_sum_yearly.append(da_zarr_aggregated_sum_yearly)

        else:
            print(str("skipping " + filename))

    # save csv files
    os.makedirs(os.path.join(out_folder, row_o['variable_name']), exist_ok=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] + "_basin_sum_daily.csv")
    pd.concat(aggregated_sum_daily).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] + "_basin_sum_daily_rolling.csv")
    pd.concat(aggregated_sum_daily_rolling).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] + "_basin_sum_monthly.csv")
    pd.concat(aggregated_sum_monthly).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] + "_basin_sum_yearly.csv")
    pd.concat(aggregated_sum_yearly).to_csv(filename, index=True)
