import xarray as xr
import matplotlib.pyplot as plt
import matplotlib.axes as axs
import pandas as pd
import numpy as np
import os
import zarr
import geopandas as gpd


spinup_run = False

## Output figure folder

ghod_region_filename = "region.gpkg"
ghod_region = gpd.read_file(ghod_region_filename)

## Prepare soil data for normalization
soil_data_filename = "soil_layer_forest_height_m_m.zarr"
da_zarr_soil = xr.open_zarr(soil_data_filename, consolidated=False)
da_zarr_soil.rio.write_crs(ghod_region.crs, inplace=True)
da_zarr_soil = da_zarr_soil.rio.clip(
    ghod_region.geometry,
    ghod_region.crs,
    drop=True
)

da_zarr_soil = da_zarr_soil.mean(dim=["time"])


## Import soil moisture data

filename = "GEB_step4_hb_af_00/soil_moisture_forest_m.zarr"

figure_directory_run = "."
if not (os.path.exists(figure_directory_run)):
    os.makedirs(figure_directory_run)

da_zarr = xr.open_zarr(filename, consolidated=False)

## Cut to region size
da_zarr.rio.write_crs(ghod_region.crs, inplace=True)
da_zarr = da_zarr.rio.clip(
    ghod_region.geometry,
    ghod_region.crs,
    drop=True
)

## Normalise soil moisture
da_zarr = da_zarr['soil_moisture_forest_m'] / da_zarr_soil['soil_layer_forest_height_m_m']

## Yearly Average for 2049
yearly_data = da_zarr.sel(time=slice("2049-01-01", "2049-12-31")).mean(dim=["time"])
da_yearly_data = yearly_data.assign_attrs(long_name ='Normalized Soil Moisture', unit = "m/m")

fig = da_yearly_data.plot().figure
plt.title(str("Average Daily ") + row_o['scale'] + " " + row_o['title'] + " in " + year)
plt.ylabel("latitude")
plt.xlabel("longitude")

figure_filename = str(figure_directory_run + row_o['variable'] + "_" + row_o['scale'] + "_average_daily_" + year + ".png")
fig.savefig(figure_filename, dpi = 200)
fig.clear()
