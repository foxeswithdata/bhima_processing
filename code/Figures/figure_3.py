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
import matplotlib.pyplot as plt
import geopandas as gpd
import rioxarray
import os
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

## Prepare soil data for normalization
soil_data_filename = "data/soil_layer_forest_height_m_m.zarr"
da_zarr_soil = xr.open_zarr(soil_data_filename, consolidated=False)
da_zarr_soil.rio.write_crs(ghod_region.crs, inplace=True)
da_zarr_soil = da_zarr_soil.rio.clip(ghod_region.geometry, ghod_region.crs, drop=True)

da_zarr_soil = da_zarr_soil.mean(dim=["time"])

#### FIGURE 10 - combine two figures in outside software ?

target_months = [3, 6, 9, 12]  # March, June, September, December

## Import soil moisture data for default run
filename = "data/ssp3_out/GEB_step4/hydrology.soil/soil_moisture_forest_m.zarr"
da_zarr_GEB = xr.open_zarr(filename, consolidated=False)

filename = "data/ssp3_out/GEB_step4_hb_af_00/hydrology.soil/soil_moisture_forest_m.zarr"
da_zarr_PF = xr.open_zarr(filename, consolidated=False)

## Cut to region size
da_zarr_PF.rio.write_crs(ghod_region.crs, inplace=True)
da_zarr_PF = da_zarr_PF.rio.clip(ghod_region.geometry, ghod_region.crs, drop=True)

## Normalise soil moisture
da_zarr_GEB = (
    da_zarr_GEB["soil_moisture_forest_m"] / da_zarr_soil["soil_layer_forest_height_m_m"]
)
da_zarr_PF = (
    da_zarr_PF["soil_moisture_forest_m"] / da_zarr_soil["soil_layer_forest_height_m_m"]
)

def get_monthly_mean(da, year="2049"):
    monthly = (
        da.sel(time=slice(f"{year}-01-01", f"{year}-12-31"))
        .groupby("time.month")
        .mean(dim=["time"])
    )
    return monthly.sel(month=target_months)

data_GEB = get_monthly_mean(da_zarr_GEB)
data_PF = get_monthly_mean(da_zarr_PF)

# data_GEB = data_GEB.assign_attrs(
#     long_name="Normalised Soil Moisture", units="m/m"
# )
# data_PF = data_PF.assign_attrs(
#     long_name="Normalised Soil Moisture", units="m/m"
# )

# --- Shared color scale (optional but recommended) ---
vmin = min(float(data_GEB.min()), float(data_PF.min()))
vmax = max(float(data_GEB.max()), float(data_PF.max()))

# --- Extent and ticks (reuse your existing logic) ---
x_min = float(data_GEB["x"].min().values)
x_max = float(data_GEB["x"].max().values)
y_min = float(data_GEB["y"].min().values)
y_max = float(data_GEB["y"].max().values)
x_pad = (x_max - x_min) * 0.03
y_pad = (y_max - y_min) * 0.03
x_ticks = np.arange(np.floor(x_min * 10) / 10, np.ceil(x_max * 10) / 10 + 0.1, 0.1)
y_ticks = np.arange(np.floor(y_min * 10) / 10, np.ceil(y_max * 10) / 10 + 0.1, 0.1)

# --- Build figure: 4 rows x 2 cols ---
n_rows = len(target_months)  # 4
n_cols = 2

fig, axes = plt.subplots(
    n_rows, n_cols,
    figsize=(8, 12),
    subplot_kw={"projection": ccrs.PlateCarree()},
)

dataset_titles = ["GEB", "GEB-PlantFATE"]  # Adjust to your actual names

for row, month in enumerate(target_months):
    for col, (data, ds_title) in enumerate(zip([data_GEB, data_PF], dataset_titles)):
        ax = axes[row, col]
        month_data = data.sel(month=month)

        img = ax.pcolormesh(
            month_data["x"].values,
            month_data["y"].values,
            month_data.values,
            transform=ccrs.PlateCarree(),
            vmin=vmin,
            vmax=vmax,
            zorder=10000,
        )

        ax.set_extent(
            [x_min - x_pad, x_max + x_pad, y_min - y_pad, y_max + y_pad],
            crs=ccrs.PlateCarree()
        )

        # Row labels (month names) on the left
        if col == 0:
            ax.text(
                -0.17, 0.5,                      # x slightly outside axes, y centered
                calendar.month_name[month],
                transform=ax.transAxes,           # relative to this axes
                fontsize=9,
                fontweight="bold",
                va="center",
                ha="right",
                rotation=90,                      # remove this line if you prefer horizontal
            )
        # Column titles on top row
        if row == 0:
            ax.set_title(ds_title, fontsize=9, fontweight="bold", pad=4)

        # Gridlines with selective axis labels
        is_left = col == 0
        is_bottom = row == n_rows - 1

        gl = ax.gridlines(
            draw_labels=True, zorder=-1, linewidth=0.6, color="gray", alpha=0.6
        )
        gl.xlocator = mticker.FixedLocator(x_ticks)
        gl.ylocator = mticker.FixedLocator(y_ticks)
        gl.top_labels = False
        gl.right_labels = False
        gl.left_labels = is_left
        gl.bottom_labels = is_bottom
        gl.xlabel_style = {"size": 7}
        gl.ylabel_style = {"size": 7}

# --- Shared colorbar ---
fig.subplots_adjust(bottom=0.1, top=0.95, hspace=0.05, wspace=0.08)
cbar_ax = fig.add_axes([0.25, 0.06, 0.5, 0.02])
fig.colorbar(
    img,
    cax=cbar_ax,
    orientation="horizontal",
    label="Normalized Soil Moisture [m/m]",
)

plt.savefig(figure_directory_run + "normalized_soil_moisture_comparison_2049.tif", dpi=150, bbox_inches="tight")
# plt.show()
#
# fig_facet = da_monthly_data.plot(
#     x="x", y="y", col="month", col_wrap=3,
#     subplot_kws={"projection": ccrs.PlateCarree()},
#     transform=ccrs.PlateCarree(),
#     add_colorbar=False,
# )
#
# month_names = [calendar.month_name[int(m)] for m in da_monthly_data["month"].values]
# for ax, name in zip(fig_facet.axs.flat, month_names, strict=False):
#     ax.set_title(name, fontsize=9, fontweight="bold", pad=2)
#
# x_min = float(da_monthly_data["x"].min().values)
# x_max = float(da_monthly_data["x"].max().values)
# y_min = float(da_monthly_data["y"].min().values)
# y_max = float(da_monthly_data["y"].max().values)
# x_pad = (x_max - x_min) * 0.03
# y_pad = (y_max - y_min) * 0.03
# x_ticks = np.arange(np.floor(x_min * 10) / 10, np.ceil(x_max * 10) / 10 + 0.1, 0.1)
# y_ticks = np.arange(np.floor(y_min * 10) / 10, np.ceil(y_max * 10) / 10 + 0.1, 0.1)
#
# for ax in fig_facet.axs.flat:
#     ax.set_extent([x_min - x_pad, x_max + x_pad, y_min - y_pad, y_max + y_pad], crs=ccrs.PlateCarree())
#     ax.set_axisbelow(True)
#     gl = ax.gridlines(draw_labels=False, zorder=-1, linewidth=0.6, color="gray", alpha=0.6)
#     gl.xlocator = mticker.FixedLocator(x_ticks)
#     gl.ylocator = mticker.FixedLocator(y_ticks)
#     ax.coastlines()
#     ax.add_feature(cfeature.BORDERS, linestyle=":")
#
# figure_filename = str(
#     figure_directory_run + "normalized_soil_moisture_default_monthly_2049" + ".tif"
# )
# fig_facet.fig.set_size_inches(10, 7)
# fig_facet.fig.subplots_adjust(bottom=0.12, top=0.92, hspace=0.12, wspace=0.05)
# mappable = fig_facet.axs.flat[0].collections[0]
# cbar_ax = fig_facet.fig.add_axes([0.25, 0.06, 0.5, 0.03])
# fig_facet.fig.colorbar(
#     mappable,
#     cax=cbar_ax,
#     orientation="horizontal",
#     label="Normalised Soil Moisture (m/m)",
# )
#
# fig_facet.fig.savefig(figure_filename, dpi=200, bbox_inches="tight")
# fig_facet.fig.clear()
#
# ## Import data for HB scenario
#
# filename = "data/ssp3_out/GEB_step4_hb_af_00/hydrology.soil/soil_moisture_forest_m.zarr"
#
# da_zarr = xr.open_zarr(filename, consolidated=False)
#
# ## Cut to region size
# da_zarr.rio.write_crs(ghod_region.crs, inplace=True)
# da_zarr = da_zarr.rio.clip(ghod_region.geometry, ghod_region.crs, drop=True)
#
# ## Normalise soil moisture
# da_zarr = (
#     da_zarr["soil_moisture_forest_m"] / da_zarr_soil["soil_layer_forest_height_m_m"]
# )
#
# ## Monthly Average for 2049
# monthly_data = (
#     da_zarr.sel(time=slice("2049-01-01", "2049-12-31"))
#     .groupby("time.month")
#     .mean(dim=["time"])
# )
# da_monthly_data = monthly_data.assign_attrs(
#     long_name="Normalised Soil Moisture", units="m/m"
# )
#
# fig_facet = da_monthly_data.plot(
#     x="x", y="y", col="month", col_wrap=3,
#     subplot_kws={"projection": ccrs.PlateCarree()},
#     transform=ccrs.PlateCarree(),
#     add_colorbar=False,
#     zorder=10000,
# )
#
# month_names = [calendar.month_name[int(m)] for m in da_monthly_data["month"].values]
# for ax, name in zip(fig_facet.axs.flat, month_names, strict=False):
#     ax.set_title(name, fontsize=9, fontweight="bold", pad=2)
#
# x_min = float(da_monthly_data["x"].min().values)
# x_max = float(da_monthly_data["x"].max().values)
# y_min = float(da_monthly_data["y"].min().values)
# y_max = float(da_monthly_data["y"].max().values)
# x_pad = (x_max - x_min) * 0.03
# y_pad = (y_max - y_min) * 0.03
# x_ticks = np.arange(np.floor(x_min * 10) / 10, np.ceil(x_max * 10) / 10 + 0.1, 0.1)
# y_ticks = np.arange(np.floor(y_min * 10) / 10, np.ceil(y_max * 10) / 10 + 0.1, 0.1)
#
# for ax in fig_facet.axs.flat:
#     ax.set_extent([x_min - x_pad, x_max + x_pad, y_min - y_pad, y_max + y_pad], crs=ccrs.PlateCarree())
#     ax.set_axisbelow(True)
#     gl = ax.gridlines(draw_labels=False, zorder=0, linewidth=0.6, color="gray", alpha=0.6)
#     gl.xlocator = mticker.FixedLocator(x_ticks)
#     gl.ylocator = mticker.FixedLocator(y_ticks)
#
# # Note: Overwriting the previous filename here, as in the original script
# figure_filename = str(
#     figure_directory_run + "normalized_soil_moisture_default_monthly_2049" + ".tif"
# )
# fig_facet.fig.set_size_inches(10, 9)
# fig_facet.fig.subplots_adjust(bottom=0.12, top=0.92, hspace=0.12, wspace=0.05)
# mappable = fig_facet.axs.flat[0].collections[0]
# cbar_ax = fig_facet.fig.add_axes([0.25, 0.08, 0.5, 0.02])
# fig_facet.fig.colorbar(
#     mappable,
#     cax=cbar_ax,
#     orientation="horizontal",
#     label="Normalised Soil Moisture (m/m)",
# )

# fig_facet.fig.savefig(figure_filename, dpi=20_default0, bbox_inches="tight")
# fig_facet.fig.clear()
