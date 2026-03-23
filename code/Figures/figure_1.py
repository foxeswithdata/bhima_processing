# /// script
# dependencies = [
#   "cartopy",
#   "geopandas",
#   "matplotlib",
#   "numpy",
#   "rioxarray",
#   "xarray",
#   "zarr",
# ]
# ///
import os

import xarray as xr
import matplotlib.pyplot as plt
import geopandas as gpd
import rioxarray
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import numpy as np
import matplotlib.ticker as mticker



os.chdir("../..")
figure_directory_run = "out/ssp3/maps/"

## Output figure folder

ghod_region_filename = "data/maps/region.gpkg"
ghod_region = gpd.read_file(ghod_region_filename)

## Prepare soil data for normalization
soil_data_filename = "data/soil_layer_forest_height_m_m.zarr"
da_zarr_soil = xr.open_zarr(soil_data_filename, consolidated=False)
da_zarr_soil.rio.write_crs(ghod_region.crs, inplace=True)
da_zarr_soil = da_zarr_soil.rio.clip(ghod_region.geometry, ghod_region.crs, drop=True)

da_zarr_soil = da_zarr_soil.mean(dim=["time"])

#### FIGURE 6

## Import soil moisture data

filename = "data/ssp3_out/GEB_step4_hb_af_00/hydrology.soil/soil_moisture_forest_m.zarr"

da_zarr = xr.open_zarr(filename, consolidated=False)

## Cut to region size
da_zarr.rio.write_crs(ghod_region.crs, inplace=True)
da_zarr = da_zarr.rio.clip(ghod_region.geometry, ghod_region.crs, drop=True)

## Normalise soil moisture
da_zarr = (
    da_zarr["soil_moisture_forest_m"] / da_zarr_soil["soil_layer_forest_height_m_m"]
)

## Yearly Average for 2049
yearly_data = da_zarr.sel(time=slice("2049-01-01", "2049-12-31")).mean(dim=["time"])
da_yearly_data = yearly_data.assign_attrs(
    long_name="Normalized Soil Moisture", unit="m/m"
)


fig = plt.figure(figsize=(7.5, 4.3))
ax = plt.axes(projection=ccrs.PlateCarree())

x_min = float(da_yearly_data["x"].min().values)
x_max = float(da_yearly_data["x"].max().values)
y_min = float(da_yearly_data["y"].min().values)
y_max = float(da_yearly_data["y"].max().values)
x_pad = (x_max - x_min) * 0.03
y_pad = (y_max - y_min) * 0.03
x_ticks = np.arange(np.floor(x_min * 10) / 10, np.ceil(x_max * 10) / 10 + 0.1, 0.1)
y_ticks = np.arange(np.floor(y_min * 10) / 10, np.ceil(y_max * 10) / 10 + 0.1, 0.1)

mappable = da_yearly_data.plot(
    ax=ax,
    transform=ccrs.PlateCarree(),
    add_colorbar=False,
    zorder=10000,
)

ax.set_extent([x_min - x_pad, x_max + x_pad, y_min - y_pad, y_max + y_pad], crs=ccrs.PlateCarree())
ax.set_axisbelow(True)
gl = ax.gridlines(draw_labels=True, zorder=0, linewidth=0.6, color="gray", alpha=0.6)
gl.xlocator = mticker.FixedLocator(x_ticks)
gl.ylocator = mticker.FixedLocator(y_ticks)
gl.top_labels = False
gl.right_labels = False

plt.title("Average Daily Forest Normalized Soil Moisture in 2049", fontsize=11, fontweight="bold")

figure_filename = str(
    figure_directory_run + "normalized_soil_moisture_hb_af00_2049" + ".tif"
)
fig.subplots_adjust(bottom=0.13, top=0.92)
cbar_ax = fig.add_axes([0.25, 0.07, 0.5, 0.03])
vmin = float(mappable.get_array().min())
vmax = float(mappable.get_array().max())
vmin_rounded = np.floor(vmin * 100) / 100
vmax_rounded = np.ceil(vmax * 100) / 100
ticks = np.linspace(vmin_rounded, vmax_rounded, 6)
fig.colorbar(
    mappable,
    cax=cbar_ax,
    orientation="horizontal",
    label="Normalized Soil Moisture (m/m)",
    ticks=ticks,
)

fig.savefig(figure_filename, dpi=300, bbox_inches="tight")
fig.clear()

figure_filename = str(
    figure_directory_run + "normalized_soil_moisture_hb_af00_2049" + ".png"
)
fig.subplots_adjust(bottom=0.13, top=0.92)
cbar_ax = fig.add_axes([0.25, 0.07, 0.5, 0.03])
vmin = float(mappable.get_array().min())
vmax = float(mappable.get_array().max())
vmin_rounded = np.floor(vmin * 100) / 100
vmax_rounded = np.ceil(vmax * 100) / 100
ticks = np.linspace(vmin_rounded, vmax_rounded, 6)
fig.colorbar(
    mappable,
    cax=cbar_ax,
    orientation="horizontal",
    label="Normalized Soil Moisture (m/m)",
    ticks=ticks,
)

fig.savefig(figure_filename, dpi=300, bbox_inches="tight")
fig.clear()