import numpy as np
import pandas as pd
import xarray as xr
import os
import geopandas as gpd

### STEP 4 data

# --- region of interest, used to clip every zarr dataset to the study area ---
ghod_region = gpd.read_file("../data/maps/region.gpkg")
out_folder = "out/ssp3/spatial_preprocessing/"

data_folder = "data/ssp3_out/"

# --- simulation scenarios: one folder per afforestation level x biodiversity setting,
# plus the "no afforestation" baseline (GEB_step4) ---
simulations = ["GEB_step4_hb_af_00", "GEB_step4_hb_af_02", "GEB_step4_hb_af_04", "GEB_step4_hb_af_06", "GEB_step4_hb_af_08", "GEB_step4_hb_af_10",
               "GEB_step4_lb_af_00", "GEB_step4_lb_af_02", "GEB_step4_lb_af_04", "GEB_step4_lb_af_06", "GEB_step4_lb_af_08", "GEB_step4_lb_af_10",
               "GEB_step4"]
biodiversity = ["high", "low"]
afforestation = pd.array([0, 0.2, 0.4, 0.6, 0.8, 10])
afforestation_str = pd.array(["00", "02", "04", "06", "08", "10"])

# --- forest-scale and plantfate-scale output variables to process ---
outputs = ["groundwater_recharge_forest_m.zarr", "soil_moisture_forest_m.zarr", "transpiration_forest_m.zarr"]
outputs_pf = [ "groundwater_recharge_plantfate_m.zarr", "soil_moisture_plantfate_m.zarr", "transpiration_plantfate_m.zarr", "biomass_forest_plantFATE.zarr", "NPP_forest_plantFATE.zarr",]
all_outputs = outputs + outputs_pf

# --- one row per simulation, carrying its afforestation level and biodiversity setting ---
sim_df = pd.DataFrame(data = {'file_name': simulations,
                              'afforestation': np.concat([afforestation, afforestation, ["na"]]),
                              'afforestation_str': np.concat([afforestation_str, afforestation_str, ["na"]]),
                              'biodiversity': np.concat([np.repeat(biodiversity, 6), ["na"]]),
                              'plantFATE': np.concat([np.repeat(True, 12), [False]])})

# --- one row per output variable, with:
#   file_name     -> the zarr file to open
#   scale         -> "forest" or "plantfate", used to pick the matching area zarr
#   variable_name -> clean short name, used for output filenames/columns
#   variable_zarr -> the actual data-variable name inside the zarr file ---
outputs_all_df = pd.DataFrame(data = {'file_name': all_outputs,
                                  'scale': np.concat([np.repeat("forest", 3), np.repeat("plantfate", 5)]),
                                  'variable_name': ['groundwater_recharge', 'soil_moisture', 'transpiration',
                                              'groundwater_recharge', 'soil_moisture', 'transpiration',  'biomass', 'NPP'],
                                  'variable_zarr': ['groundwater_recharge_forest_m', 'soil_moisture_forest_m', 'transpiration_forest_m',
                                              'groundwater_recharge_plantfate_m', 'soil_moisture_plantfate_m', 'transpiration_plantfate_m',  'biomass_forest_plantFATE', 'NPP_forest_plantFATE']})

# --- soil layer depth, used to convert soil_moisture from a water-height (m)
# into a relative moisture fraction. Averaged over time since depth is assumed
# constant across the simulation period. ---
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

outputs_df = outputs_all_df.tail(3)
print(outputs_df)
sim_df_sub = sim_df
print(sim_df_sub)

# ============================================================
# For each output variable, aggregate across all simulations at
# daily / rolling-14-day / monthly / yearly / monsoon / dry-season scales.
# ============================================================
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
            # --- load the raw variable and clip to the study region ---
            da_zarr = xr.open_zarr(filename, consolidated=False)
            da_zarr.rio.write_crs(ghod_region.crs, inplace=True)
            da_zarr = da_zarr.rio.clip(
                ghod_region.geometry,
                ghod_region.crs,
                drop=True
            )

            # soil_moisture is stored as a water height (m); convert it into a
            # relative moisture fraction by dividing by the soil layer depth.
            # Every other variable is used as-is, just selected out of the Dataset
            # so we end up with a DataArray rather than a multi-variable Dataset.
            if row_o['variable_name'] == "soil_moisture":
                da_zarr = da_zarr[row_o['variable_zarr']]  / da_zarr_soil['soil_layer_forest_height_m_m']
                da_zarr.rename(row_o['variable_zarr'])
            else:
                da_zarr = da_zarr[row_o['variable_zarr']]

            # --- build the path to the matching area zarr (m2 of forest/plantfate
            # cover per cell) for this simulation's afforestation level and scale ---
            filename_area = str("data/GEB_step4_test_new_forest_area_af_" +
                                row['afforestation_str'] +
                                "_lb/hydrology.soil/" +
                                row_o['scale'] +
                                "_area_m2.zarr")

            # the "na" (no-afforestation) baseline simulation doesn't have its own
            # area file, so fall back to the af_00 forest area as a stand-in
            if row['afforestation'] == 'na':
                filename_area = "../data/GEB_step4_test_new_forest_area_af_00_lb/hydrology.soil/forest_area_m2.zarr"


            da_zarr_area = xr.open_zarr(filename_area, consolidated=False)
            da_zarr_area.rio.write_crs(ghod_region.crs, inplace=True)
            da_zarr_area = da_zarr_area.rio.clip(
                ghod_region.geometry,
                ghod_region.crs,
                drop=True
            )

            # Area is constant across the entire simuilation so taking a selection of the area to remove the time dimension
            da_zarr_area = da_zarr_area.sel(time="2020-01-06")

            # total covered area across the region, used to normalize the weighting
            # below so weights sum to 1 rather than scaling with absolute area
            total_area = float(da_zarr_area[str(row_o['scale'] + '_area_m2')].sum())

            # area-weighted value per cell: cells with more cover contribute more
            # to the eventual spatial average. Dividing by total_area means that
            # summing this over x,y later gives a proper area-weighted MEAN
            # (not a total) -- i.e. Σ(value_i * area_i) / Σ(area_i)
            da_zarr_normalized = (da_zarr * da_zarr_area[str(row_o['scale'] + '_area_m2')]) / total_area

            print(da_zarr_normalized)

            # ---------------- MONTHLY AVERAGE ----------------
            # mean across days within each year-month, then sum the (already
            # area-weighted) per-cell contributions across space
            da_aggregated_monthly = (da_zarr_normalized.groupby(["time.month", "time.year"]).mean(dim=['time'], skipna=True)
                                     .sum(dim=["x", "y"], skipna=True)
                                     .to_dataframe(name = row_o['variable_name']))
            da_aggregated_monthly['afforestation'] = row['afforestation']
            da_aggregated_monthly['biodiversity'] = row['biodiversity']
            da_aggregated_monthly = da_aggregated_monthly.drop('spatial_ref', axis=1)
            da_aggregated_monthly = da_aggregated_monthly.drop('crs', axis=1)
            aggregated_monthly.append(da_aggregated_monthly)

            # ---------------- YEARLY AVERAGE ----------------
            da_aggregated_yearly = (da_zarr_normalized.groupby("time.year").mean(dim=['time'], skipna=True)
                                    .sum(dim=["x", "y"], skipna=True)
                                    .to_dataframe(name = row_o['variable_name']))
            da_aggregated_yearly['afforestation'] = row['afforestation']
            da_aggregated_yearly['biodiversity'] = row['biodiversity']
            da_aggregated_yearly = da_aggregated_yearly.drop('spatial_ref', axis=1)
            da_aggregated_yearly = da_aggregated_yearly.drop('crs', axis=1)
            aggregated_yearly.append(da_aggregated_yearly)

            # ---------------- MONSOON-SEASON AVERAGE (Jun-Aug), per year ----------------
            da_aggregated_monsoon = (da_zarr_normalized.sel(
                time=is_monsoon(da_zarr_normalized['time.month'])).groupby("time.year").mean(dim=['time'], skipna=True)
                                     .sum(dim=["x", "y"], skipna=True)
                                     .to_dataframe(name = row_o['variable_name']))
            da_aggregated_monsoon['afforestation'] = row['afforestation']
            da_aggregated_monsoon['biodiversity'] = row['biodiversity']
            da_aggregated_monsoon = da_aggregated_monsoon.drop('spatial_ref', axis=1)
            da_aggregated_monsoon = da_aggregated_monsoon.drop('crs', axis=1)
            aggregated_monsoon.append(da_aggregated_monsoon)

            # ---------------- DRY-SEASON AVERAGE (Jan-Mar), per year ----------------
            da_aggregated_dry = (da_zarr_normalized.sel(
                time=is_dry(da_zarr_normalized['time.month'])).groupby("time.year").mean(dim=['time'], skipna=True)
                                 .sum(dim=["x", "y"], skipna=True)
                                 .to_dataframe(name = row_o['variable_name']))
            da_aggregated_dry['afforestation'] = row['afforestation']
            da_aggregated_dry['biodiversity'] = row['biodiversity']
            da_aggregated_dry = da_aggregated_dry.drop('spatial_ref', axis=1)
            da_aggregated_dry = da_aggregated_dry.drop('crs', axis=1)
            aggregated_dry.append(da_aggregated_dry)

            # ---------------- 14-DAY ROLLING AVERAGE ----------------
            # sum the area-weighted values across space per day first, then take
            # a rolling mean over time to smooth out day-to-day noise
            da_aggregated_rolling = da_zarr_normalized.sum(dim = ["x", "y"], skipna=True).rolling(time=14).mean(skipna=True).to_dataframe(name = row_o['variable_name'])
            da_aggregated_rolling['afforestation'] = row['afforestation']
            da_aggregated_rolling['biodiversity'] = row['biodiversity']
            da_aggregated_rolling = da_aggregated_rolling.drop('spatial_ref', axis=1)
            da_aggregated_rolling = da_aggregated_rolling.drop('crs', axis=1)
            aggregated_rolling.append(da_aggregated_rolling)

            # ---------------- DAILY AVERAGE ----------------
            # spatial sum of the area-weighted values, one value per day, no time aggregation
            da_aggregated_daily = da_zarr_normalized.sum(dim=["x", "y"], skipna=True).to_dataframe(name = row_o['variable_name'])
            da_aggregated_daily['biodiversity'] = row['biodiversity']
            da_aggregated_daily['afforestation'] = row['afforestation']
            da_aggregated_daily = da_aggregated_daily.drop('spatial_ref', axis=1)
            da_aggregated_daily = da_aggregated_daily.drop('crs', axis=1)
            aggregated_daily.append(da_aggregated_daily)

        else:
            print(str("skipping " + filename))

    #save csv files, one subfolder per variable
    os.makedirs(os.path.join(out_folder, row_o['variable_name']), exist_ok=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] + "_average_monthly.csv")
    pd.concat(aggregated_monthly).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] + "_average_yearly.csv")
    pd.concat(aggregated_yearly).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] +"_average_monsoon.csv")
    pd.concat(aggregated_monsoon).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] + "_average_dry_season.csv")
    pd.concat(aggregated_dry).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] + "_rolling_average_14_days.csv")
    pd.concat(aggregated_rolling).to_csv(filename, index=True)

    filename = str(out_folder + row_o['variable_name'] + '/' + row_o['variable_name'] + "_" + row_o['scale'] + "_average_daily.csv")
    pd.concat(aggregated_daily).to_csv(filename, index=True)

