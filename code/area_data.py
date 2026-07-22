import numpy as np
import pandas as pd
import xarray as xr
import os
import geopandas as gpd

os.chdir("..")

ghod_region = gpd.read_file("data/maps/region.gpkg")

data_folder = "data/ssp3_out/"
simulations = ["GEB_step4_hb_af_00", "GEB_step4_hb_af_02", "GEB_step4_hb_af_04", "GEB_step4_hb_af_06", "GEB_step4_hb_af_08", "GEB_step4_hb_af_10",
               "GEB_step4_lb_af_00", "GEB_step4_lb_af_02", "GEB_step4_lb_af_04", "GEB_step4_lb_af_06", "GEB_step4_lb_af_08", "GEB_step4_lb_af_10"]
biodiversity = ["high", "low"]
afforestation = pd.array([0, 0.2, 0.4, 0.6, 0.8, 10])
afforestation_str = pd.array(["00", "02", "04", "06", "08", "10"])

sim_df = pd.DataFrame(data = {'file_name': simulations,
                              'afforestation': np.concat([afforestation, afforestation]),
                              'afforestation_str': np.concat([afforestation_str, afforestation_str]),
                              'biodiversity': np.concat([np.repeat(biodiversity, 6)]),
                              'plantFATE': np.concat([np.repeat(True, 12)])})


for index, row in sim_df.iterrows():

    for scale in ["forest", "plantfate"]:

        filename_area = str("data/GEB_step4_test_new_forest_area_af_" +
                            row['afforestation_str'] +
                            "_lb/hydrology.soil/" +
                            scale +
                            "_area_m2.zarr")

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
        area_var = scale + '_area_m2'

        area_sum = da_zarr_area.sum(
            dim=["x", "y"],
            skipna=True
        )

        print("Area m2 in afforestation " + row['afforestation_str'] + " scale: " + scale)
        # print data variable from data series area_sum
        print(area_sum[area_var].values)

        print("Area ha in afforestation " + row['afforestation_str'] + " scale: " + scale)
        print(area_sum[area_var].values * 0.0001)