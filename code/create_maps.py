import xarray as xr
import matplotlib.pyplot as plt
import matplotlib.axes as axs
import pandas as pd
import numpy as np
import os
import zarr
import geopandas as gpd

os.chdir("..")

spinup_run = False

## Output figure folder

ghod_region = gpd.read_file("data/maps/region.gpkg")

### STEP 3 data

data_folder = "data/ssp3_out/"
simulations = ["GEB_step3_default_spinup", "GEB_step3_plantfate_hb_spinup", "GEB_step3_plantfate_lb_spinup"]
biodiversity = ["na", "high", "low"]
sim_df_step3 = pd.DataFrame(data = {'file_name': simulations,
                              'biodiversity': biodiversity,
                              'plantFATE': [False, True, True]})

print(sim_df_step3)

### STEP 4 data

data_folder = "data/ssp3_out/"
simulations = ["GEB_step4_hb_af_00", "GEB_step4_hb_af_02", "GEB_step4_hb_af_04", "GEB_step4_hb_af_06", "GEB_step4_hb_af_08", "GEB_step4_hb_af_10",
               "GEB_step4_lb_af_00", "GEB_step4_lb_af_02", "GEB_step4_lb_af_04", "GEB_step4_lb_af_06", "GEB_step4_lb_af_08", "GEB_step4_lb_af_10",
               "GEB_step4"]
biodiversity = ["high", "low"]
afforestation = pd.array([0, 0.2, 0.4, 0.6, 0.8, 10])
outputs = ["groundwater_recharge_forest_m.zarr", "soil_moisture_forest_m.zarr", "transpiration_forest_m.zarr"]
outputs_pf = [ "groundwater_recharge_plantfate_m.zarr", "soil_moisture_plantfate_m.zarr",
               "transpiration_plantfate_m.zarr", "biomass_forest_plantFATE.zarr", "NPP_forest_plantFATE.zarr",]
all_outputs = outputs + outputs_pf

sim_df = pd.DataFrame(data = {'file_name': simulations,
                              'afforestation': np.concat([afforestation, afforestation, [None]]),
                              'biodiversity': np.concat([np.repeat(biodiversity, 6), [None]]),
                              'plantFATE': np.concat([np.repeat(True, 12), [False]])})

outputs_all_df = pd.DataFrame(data = {'file_name': all_outputs,
                                  'scale': np.concat([np.repeat("forest", 3), np.repeat("plantfate", 5)]),
                                  'variable': ['groundwater_recharge', 'soil_moisture', 'transpiration',
                                              'groundwater_recharge', 'soil_moisture', 'transpiration',  'biomass', 'NPP'],
                                      'title': ['Groundwater Recharge', 'Soil Moisture', 'Transpiration',
                                              'Groundwater Recharge', 'Soil Moisture', 'Transpiration',  'Biomass', 'NPP'],
                                      'unit': ['m', 'm', 'kgC/m2/day', 'm', 'm', 'kgC/m2/day', "kgC", "kgC/m2/day"]
                                      })
outputs_df = outputs_all_df

figure_directory = "out/ssp3/maps/"
year = "2049"
sim_df_sub = sim_df

if spinup_run:
    figure_directory = "out/ssp3/maps/spinup/"
    year = "2019"
    sim_df_sub = sim_df_step3

grid_area = 817398.837317795
non_summable = ["soil_moisture", "biomass"]

for index_o, row_o in outputs_df.iterrows():
    for index, row in sim_df_sub.iterrows():
        print("Running " + row_o['variable'] + " " + row_o['scale'] + " in " + row['file_name'])
        filename = str(data_folder + row['file_name'] + "/hydrology.soil/" + row_o['file_name'] )

        if os.path.exists(filename):

            ## Prepare data

            figure_directory_run = str(figure_directory + row['file_name'] + "/")
            if not (os.path.exists(figure_directory_run)):
                os.makedirs(figure_directory_run)

            da_zarr = xr.open_zarr(filename, consolidated=False)
            da_zarr.rio.write_crs(ghod_region.crs, inplace=True)
            da_zarr = da_zarr.rio.clip(
                ghod_region.geometry,
                ghod_region.crs,
                drop=True
            )

            ## Yearly Average
            yearly_data = da_zarr.sel(time=slice(str(year + "-01-01"), str(year + "-12-31"))).mean(dim=["time"])
            da_yearly_data = yearly_data[list(yearly_data.keys())[0]]
            da_yearly_data = da_yearly_data.assign_attrs(long_name = row_o['title'], unit = row_o['unit'])

            fig = da_yearly_data.plot().figure
            plt.title(str("Average Daily ") + row_o['scale'] + " " + row_o['title'] + " in " + year)
            plt.ylabel("latitude")
            plt.xlabel("longitude")

            figure_filename = str(figure_directory_run + row_o['variable'] + "_" + row_o['scale'] + "_average_daily_" + year + ".png")
            fig.savefig(figure_filename, dpi = 200)
            fig.clear()

            ## Yearly Sums (won't work with everything)

            if not(row_o['variable'] in non_summable):
                yearly_data = da_zarr.sel(time=slice(str(year + "-01-01"), str(year + "-12-31"))).sum(dim=["time"])
                da_yearly_data = yearly_data[list(yearly_data.keys())[0]]
                da_yearly_data = da_yearly_data.assign_attrs(long_name = row_o['title'], unit = row_o['unit'])

                fig = da_yearly_data.plot().figure
                plt.title(str("Total Annual ") + row_o['scale'] + " " + row_o['title'] + " in " + year)
                plt.ylabel("latitude")
                plt.xlabel("longitude")

                figure_filename = str(figure_directory_run + row_o['variable'] + "_" + row_o['scale'] + "_total_annual_" + year + ".png")
                fig.savefig(figure_filename, dpi = 200)
                fig.clear()

            ## Monthly Average
            monthly_data = da_zarr.sel(time=slice(str(year + "-01-01"), str(year + "-12-31"))).groupby("time.month").mean(dim=["time"])
            da_monthly_data = monthly_data[list(yearly_data.keys())[0]]
            da_monthly_data = da_monthly_data.assign_attrs(long_name=row_o['title'], units=row_o['unit'])

            fig_facet = da_monthly_data.plot(x="x", y="y", col="month", col_wrap=3)

            figure_directory_run = str(figure_directory + row['file_name'] + "/")
            if not (os.path.exists(figure_directory_run)):
                os.mkdir(figure_directory_run)
            figure_filename = str(figure_directory_run + row_o['variable'] +"_" + row_o['scale'] + "_average_daily_in_month_" + year + ".png")
            fig_facet.fig.savefig(figure_filename, dpi=200)
            fig_facet.fig.clear()

            if not(row_o['variable'] in non_summable):
                monthly_data = da_zarr.sel(time=slice(str(year + "-01-01"), str(year + "-12-31"))).groupby("time.month").sum(
                    dim=["time"])
                da_monthly_data = monthly_data[list(yearly_data.keys())[0]]
                da_monthly_data = da_monthly_data.assign_attrs(long_name=row_o['title'], units=row_o['unit'])

                fig_facet = da_monthly_data.plot(x="x", y="y", col="month", col_wrap=3)
                figure_directory_run = str(figure_directory + row['file_name'] + "/")
                if not (os.path.exists(figure_directory_run)):
                    os.mkdir(figure_directory_run)
                figure_filename = str(
                    figure_directory_run + row_o['variable'] + "_" + row_o['scale'] + "_total_monthly_" + year + ".png")
                fig_facet.fig.savefig(figure_filename, dpi=200)
                fig_facet.fig.clear()


            ## Monsoon Average
            monsoon_data = da_zarr.sel(time=slice(str(year + "-06-01"), str(year + "-08-31"))).mean(dim=["time"])
            da_monsoon_data = monsoon_data[list(monsoon_data.keys())[0]]
            da_monsoon_data = da_monsoon_data.assign_attrs(long_name = row_o['title'], unit = row_o['unit'])

            fig = da_monsoon_data.plot().figure
            plt.title(str("Monsoon Season (June-August) Average Daily ") + row_o['scale'] + " " + row_o['title'] + " in " + year)
            plt.ylabel("latitude")
            plt.xlabel("longitude")

            figure_directory_run = str(figure_directory + row['file_name'] + "/")
            if not(os.path.exists(figure_directory_run)):
                os.mkdir(figure_directory_run)
            figure_filename = str(figure_directory_run + row_o['variable'] +"_" + row_o['scale'] + "_average_daily_monsoon_season_" + year + ".png")
            fig.savefig(figure_filename, dpi = 200)
            fig.clear()

            if not (row_o['variable'] in non_summable):
                monsoon_data = da_zarr.sel(time=slice(str(year + "-06-01"), str(year + "-08-31"))).sum(dim=["time"])
                da_monsoon_data = monsoon_data[list(monsoon_data.keys())[0]]
                da_monsoon_data = da_monsoon_data.assign_attrs(long_name=row_o['title'], unit=row_o['unit'])

                fig = da_monsoon_data.plot().figure
                plt.title(str("Monsoon Season (June-August) Total ") + row_o['scale'] + " " + row_o[
                    'title'] + " in " + year)
                plt.ylabel("latitude")
                plt.xlabel("longitude")

                figure_directory_run = str(figure_directory + row['file_name'] + "/")
                if not (os.path.exists(figure_directory_run)):
                    os.mkdir(figure_directory_run)
                figure_filename = str(
                    figure_directory_run + row_o['variable'] + "_" + row_o['scale'] + "_total_monsoon_season_" + year + ".png")
                fig.savefig(figure_filename, dpi=200)
                fig.clear()

            ## Dry season Average
            dry_season_data = da_zarr.sel(time=slice(str(year + "-01-01"), str(year + "-03-31"))).mean(dim=["time"])
            da_dry_season_data = dry_season_data[list(dry_season_data.keys())[0]]
            da_dry_season_data = da_dry_season_data.assign_attrs(long_name = row_o['title'], unit = row_o['unit'])

            fig = da_dry_season_data.plot().figure
            plt.title(str("Dry Season Average Daily ") + row_o['scale'] + " " + row_o['title'] + " in " + year)
            plt.ylabel("latitude")
            plt.xlabel("longitude")

            figure_directory_run = str(figure_directory + row['file_name'] + "/")
            if not(os.path.exists(figure_directory_run)):
                os.mkdir(figure_directory_run)
            figure_filename = str(figure_directory_run + row_o['variable'] + "_" + row_o['scale'] + "_average_daily_dry_season_" + year + ".png")
            fig.savefig(figure_filename, dpi = 200)
            fig.clear()

            if not (row_o['variable'] in non_summable):
                dry_season_data = da_zarr.sel(time=slice(str(year + "-01-01"), str(year + "-03-31"))).sum(dim=["time"])
                da_dry_season_data = dry_season_data[list(dry_season_data.keys())[0]]
                da_dry_season_data = da_dry_season_data.assign_attrs(long_name=row_o['title'], unit=row_o['unit'])

                fig = da_dry_season_data.plot().figure
                plt.title(str("Dry Season (Jan-March) Total ") + row_o['scale'] + " " + row_o[
                    'title'] + " in " + year)
                plt.title(str("Dry Season Average Daily ") + row_o['scale'] + " " + row_o['title'] + " 2019")
                plt.ylabel("latitude")
                plt.xlabel("longitude")

                figure_directory_run = str(figure_directory + row['file_name'] + "/")
                figure_filename = str(
                    figure_directory_run + row_o['variable'] + "_" + row_o['scale'] + "_total_dry_season_" + year + ".png")
                fig.savefig(figure_filename, dpi=200)
                fig.clear()

            ## Monsoon Day
            monsoon_data = da_zarr.sel(time=str(year + "-07-15"))
            da_monsoon_data = monsoon_data[list(monsoon_data.keys())[0]]
            da_monsoon_data = da_monsoon_data.assign_attrs(long_name = row_o['title'], unit = row_o['unit'])

            fig = da_monsoon_data.plot().figure
            plt.title(str("Monsoon Season ") + row_o['scale'] + " " + row_o['title'] + "15.07." + year)
            plt.ylabel("latitude")
            plt.xlabel("longitude")

            figure_directory_run = str(figure_directory + row['file_name'] + "/")
            if not(os.path.exists(figure_directory_run)):
                os.mkdir(figure_directory_run)
            figure_filename = str(figure_directory_run + row_o['variable'] + "_" + row_o['scale'] + "_monsoon_season_day_example.png")
            fig.savefig(figure_filename, dpi = 200)
            fig.clear()

            ## Dry season Average
            dry_season_data = da_zarr.sel(time=str(year + "-02-01"))
            da_dry_season_data = dry_season_data[list(dry_season_data.keys())[0]]
            da_dry_season_data = da_dry_season_data.assign_attrs(long_name = row_o['title'], unit = row_o['unit'])

            fig = da_dry_season_data.plot().figure
            plt.title(str("Dry Season ") + row_o['scale'] + " " + row_o['title'] + "01.02." + year)
            plt.ylabel("latitude")
            plt.xlabel("longitude")

            figure_directory_run = str(figure_directory + row['file_name'] + "/")
            if not(os.path.exists(figure_directory_run)):
                os.mkdir(figure_directory_run)
            figure_filename = str(figure_directory_run + row_o['variable'] + "_" + row_o['scale'] + "_dry_season_day_example.png")
            fig.savefig(figure_filename, dpi = 200)
            fig.clear()

