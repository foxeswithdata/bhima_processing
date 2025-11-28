import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import xarray as xr
import os
import geopandas as gpd
import rioxarray

os.chdir("..")


ghod_region = gpd.read_file("data/maps/region.gpkg")

print(ghod_region)
print(type(ghod_region))

test_map_filename = "data/ssp3_out/GEB_step4_hb_af_06/hydrology.soil/soil_moisture_forest_m.zarr"
da_zarr = xr.open_zarr(test_map_filename, consolidated=False)


if da_zarr.rio.crs != ghod_region.crs:
    print("different crs")
    print(da_zarr.rio.crs)
    print(ghod_region.crs)
    da_zarr.rio.write_crs(ghod_region.crs, inplace=True)

    # gdf = ghod_region.to_crs(da_zarr.rio.crs)

print(da_zarr.rio.crs)
print(ghod_region.crs)

clipped_zarr = da_zarr.rio.clip(
    ghod_region.geometry,
    ghod_region.crs,
    drop=True
)

## Test unclipped

sub_data = clipped_zarr.sel(time="2039-07-01")
da_sub_daya = sub_data[list(sub_data.keys())[0]]

fig = da_sub_daya.plot().figure
plt.ylabel("latitude")
plt.xlabel("longitude")

figure_filename = str("test_clipped.png")
fig.savefig(figure_filename, dpi=200)
fig.clear()

sub_data = da_zarr.sel(time="2039-07-01")
da_sub_daya = sub_data[list(sub_data.keys())[0]]

fig = da_sub_daya.plot().figure
plt.ylabel("latitude")
plt.xlabel("longitude")

figure_filename = str("test_unclipped.png")
fig.savefig(figure_filename, dpi=200)
fig.clear()
