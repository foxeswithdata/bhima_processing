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

import xarray as xr
import os
import matplotlib.pyplot as plt
import geopandas as gpd
import rioxarray
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import numpy as np
import matplotlib.ticker as mticker
import calendar

os.chdir("../..")
figure_directory_run = "out/ssp3/maps/"

## Output figure folder

ghod_region_filename = "data/maps/region.gpkg"
ghod_region = gpd.read_file(ghod_region_filename)

#### FIGURE 7

## Import transpiration data
filename = "data/ssp3_out/GEB_step4/hydrology.soil/transpiration_forest_m.zarr"

# Load the dataset
ds_zarr = xr.open_zarr(filename, consolidated=False)

# Cut to region size (Clip the Dataset first to preserve coordinates correctly)
ds_zarr.rio.write_crs(ghod_region.crs, inplace=True)
ds_zarr = ds_zarr.rio.clip(ghod_region.geometry, ghod_region.crs, drop=True)

# Select variable
da_zarr = ds_zarr["transpiration_forest_m"]

monthly_data = (
    da_zarr.sel(time=slice("2049-01-01", "2049-12-31"))
    .groupby("time.month")
    .mean(dim=["time"])
)
da_monthly_data = monthly_data.assign_attrs(
    long_name="Transpiration", units="kg H$_2$O m$^{-2}$ day$^{-1}$"
)


fig_facet = da_monthly_data.plot(
    x="x", y="y", col="month", col_wrap=3,
    subplot_kws={"projection": ccrs.PlateCarree()},
    transform=ccrs.PlateCarree(),
    add_colorbar=False,
    zorder=10000,
)

month_names = [calendar.month_name[int(m)] for m in da_monthly_data["month"].values]
for ax, name in zip(fig_facet.axs.flat, month_names, strict=False):
    ax.set_title(name, fontsize=9, fontweight="bold", pad=2)

x_min = float(da_monthly_data["x"].min().values)
x_max = float(da_monthly_data["x"].max().values)
y_min = float(da_monthly_data["y"].min().values)
y_max = float(da_monthly_data["y"].max().values)
x_pad = (x_max - x_min) * 0.03
y_pad = (y_max - y_min) * 0.03
x_ticks = np.arange(np.floor(x_min * 10) / 10, np.ceil(x_max * 10) / 10 + 0.1, 0.1)
y_ticks = np.arange(np.floor(y_min * 10) / 10, np.ceil(y_max * 10) / 10 + 0.1, 0.1)

n_cols = 3
n_rows = len(fig_facet.axs)  # number of rows in the grid

for i, ax in enumerate(fig_facet.axs.flat):
    ax.set_extent([x_min - x_pad, x_max + x_pad, y_min - y_pad, y_max + y_pad], crs=ccrs.PlateCarree())
    ax.set_axisbelow(True)

    row = i // n_cols
    col = i % n_cols
    total = len(list(fig_facet.axs.flat))
    is_left = col == 0
    is_bottom = i >= total - n_cols  # last row

    gl = ax.gridlines(
        draw_labels=True,
        zorder=-1,
        linewidth=0.6,
        color="gray",
        alpha=0.6
    )
    gl.xlocator = mticker.FixedLocator(x_ticks)
    gl.ylocator = mticker.FixedLocator(y_ticks)

    # Suppress labels on sides that shouldn't have them
    gl.top_labels = False
    gl.right_labels = False
    gl.left_labels = is_left
    gl.bottom_labels = is_bottom

    # Optional: style the label text
    gl.xlabel_style = {"size": 7}
    gl.ylabel_style = {"size": 7}

# for ax in fig_facet.axs.flat:
#     ax.set_extent([x_min - x_pad, x_max + x_pad, y_min - y_pad, y_max + y_pad], crs=ccrs.PlateCarree())
#     ax.set_axisbelow(True)
#     gl = ax.gridlines(draw_labels=False, zorder=-1, linewidth=0.6, color="gray", alpha=0.6)
#     gl.xlocator = mticker.FixedLocator(x_ticks)
#     gl.ylocator = mticker.FixedLocator(y_ticks)

figure_filename = str(
    figure_directory_run + "transpiration_forest_average_daily_in_month_2049" + ".tif"
)
fig_facet.fig.set_size_inches(10, 9)
fig_facet.fig.subplots_adjust(bottom=0.12, top=0.92, hspace=0.12, wspace=0.05)
mappable = fig_facet.axs.flat[0].collections[0]
cbar_ax = fig_facet.fig.add_axes([0.25, 0.08, 0.5, 0.02])
fig_facet.fig.colorbar(
    mappable,
    cax=cbar_ax,
    orientation="horizontal",
    label="Transpiration (kg H$_2$O m$^{-2}$ day$^{-1}$)",
)

fig_facet.fig.savefig(figure_filename, dpi=300, bbox_inches="tight")
