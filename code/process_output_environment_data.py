import numpy as np
import xarray as xr
import os
import pandas as pd
import datetime as dt
from pathlib import Path
import itertools

os.chdir("..")

# prepare data for step 2 Plantfate

# ---- CONFIGURATION ----------------------------------------------------
# Uncomment ONE of the following.

RUN = "step1_spinup"  # or "GEB_step4_hb_af_10"

# (a) Environmental forcing for the PlantFATE spinup (GEB step 1 output)
if RUN == "step1_spinup":
    INPUT_DIR  = Path("data/prepare_plantfate_spinup")
    OUTPUT_DIR = Path("out/environmental_data_processed/step1_spinup")
else:
    # (b) Environmental diagnostics for a scenario run (GEB step 4 output)
    INPUT_DIR  = Path("data/ssp3_out/GEB_step4_hb_af_10/hydrology.soil")
    OUTPUT_DIR = Path("out/environmental_data_processed/GEB_step4_hb_af_10")
# -----------------------------------------------------------------------

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# make directory output_folder

da_temp = xr.open_zarr(
            str(INPUT_DIR + "temperature_K.zarr"),
            consolidated=False
        )
da_vpd = xr.open_zarr(
        str(INPUT_DIR + "vapour_pressure_deficit_kPa.zarr"),
            consolidated = False
        )
da_ppfd = xr.open_zarr(
            str(INPUT_DIR + "photosynthetic_photon_flux_density_W_m2.zarr"),
            consolidated = False
        )
da_swp = xr.open_zarr(
            str(INPUT_DIR + "soil_water_potential_MPa.zarr"),
            consolidated=False
        )
da_nr = xr.open_zarr(
            str(INPUT_DIR + "net_absorbed_radiation_vegetation_MJ_m2_day.zarr"),
            consolidated=False
        )


if RUN == "step1_spinup":
    print("grouping by month and year")
    da_T_aggregated = da_temp.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_T_aggregated = da_T_aggregated["temperature_K"].to_dataframe(name="temperature_C")
    da_T_aggregated["temperature_C"] = da_T_aggregated["temperature_C"] - 273.15  # K -> C
    da_vpd_aggregated = da_vpd.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_vpd_aggregated = da_vpd_aggregated["vapour_pressure_deficit_kPa"].to_dataframe(name="VPD_hPa")
    da_vpd_aggregated["VPD_hPa"] = da_vpd_aggregated["VPD_hPa"] * 10  # kPa -> hPa
    da_ppfd_aggregated = da_ppfd.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_ppfd_aggregated = da_ppfd_aggregated["photosynthetic_photon_flux_density_W_m2"].to_dataframe(name="PAR")
    da_swp_aggregated = da_swp.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_swp_aggregated = da_swp_aggregated["soil_water_potential_MPa"].to_dataframe(name="SWP")
    da_swp_aggregated["SWP"] = da_swp_aggregated["SWP"] * (-1)
    da_nr_aggregated = da_nr.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_nr_aggregated = da_nr_aggregated["net_absorbed_radiation_vegetation_MJ_m2_day"].to_dataframe(name="NR")

    # Year, Month, Decimal_year, Temp (deg C), VPD (hPa), PAR (umol m-2 s-1), PAR_max (umol m-2 s-1), SWP (-MPa, i.e., absolute value), further columns are ignored

    num_years = 5000


    # print(list(range(1,13)) * num_years)
    # print(list(da_T_aggregated) * num_years)

    yr_list = list(range(1980-num_years, 1980))
    yrs = [ele for ele in yr_list for i in range(12)]
    # print(yr_list)
    # print(yrs)
    out_put = pd.DataFrame(data = {'Year': yrs,
                                   'Month': list(range(1,13)) * num_years,
                                   'Decimal_year': np.linspace(start=(1979 - num_years + 1),stop=1979.91666666667,num = 12 * num_years),
                                   'Temp': list(da_T_aggregated) * num_years,
                                   'VPD': list(da_vpd_aggregated) * num_years,
                                   "PAR" : list(da_ppfd_aggregated) * num_years,
                                   "PAR_max" : list(da_ppfd_aggregated * 4) * num_years,
                                   "SWP" : list(da_swp_aggregated) * num_years})

    print(out_put)
    out_put.to_csv("out_data_5000.csv", index = False)

else:
    print("grouping by month and year")
    da_T_aggregated = da_temp.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_T_aggregated = da_T_aggregated["temperature_K"].to_dataframe(name="temperature_C")
    da_T_aggregated["temperature_C"] = da_T_aggregated["temperature_C"] - 273.15  # K -> C
    da_vpd_aggregated = da_vpd.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_vpd_aggregated = da_vpd_aggregated["vapour_pressure_deficit_kPa"].to_dataframe(name = "VPD_hPa")
    da_vpd_aggregated["VPD_hPa"] = da_vpd_aggregated["VPD_hPa"] * 10 # kPa -> hPa
    da_ppfd_aggregated = da_ppfd.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_ppfd_aggregated = da_ppfd_aggregated["photosynthetic_photon_flux_density_W_m2"].to_dataframe(name = "PAR")
    da_swp_aggregated = da_swp.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_swp_aggregated = da_swp_aggregated["soil_water_potential_MPa"].to_dataframe(name = "SWP")
    da_swp_aggregated["SWP"] = da_swp_aggregated["SWP"] * (-1)
    da_nr_aggregated = da_nr.groupby(["time.year", "time.month"]).mean(dim=["time", "x", "y"])
    da_nr_aggregated = da_nr_aggregated["net_absorbed_radiation_vegetation_MJ_m2_day"].to_dataframe(name = "NR")

    print(da_vpd_aggregated)
    print(da_ppfd_aggregated)
    print(da_swp_aggregated)
    print(da_nr_aggregated)

    da_merge = pd.merge(da_T_aggregated, da_vpd_aggregated, left_index=True, right_index=True)
    da_merge = pd.merge(da_merge, da_ppfd_aggregated, left_index=True, right_index=True)
    da_merge = pd.merge(da_merge, da_swp_aggregated, left_index=True, right_index=True)
    da_merge = pd.merge(da_merge, da_nr_aggregated, left_index=True, right_index=True)

    outpath = Path(OUTPUT_DIR, "out_data_monthly.csv")
    print(outpath)
    da_merge.to_csv(outpath, index = True)

    print("grouping by year")

    da_T_aggregated = da_temp.groupby("time.year").mean(dim=["time", "x", "y"])
    da_T_aggregated = da_T_aggregated["temperature_K"].to_dataframe(name="temperature_C")
    da_T_aggregated["temperature_C"] = da_T_aggregated["temperature_C"] - 273.15  # K -> C
    da_vpd_aggregated = da_vpd.groupby("time.year").mean(dim=["time", "x", "y"])
    da_vpd_aggregated = da_vpd_aggregated["vapour_pressure_deficit_kPa"].to_dataframe(name = "VPD_hPa")
    da_vpd_aggregated["VPD_hPa"] = da_vpd_aggregated["VPD_hPa"] * 10 # kPa -> hPa
    da_ppfd_aggregated = da_ppfd.groupby("time.year").mean(dim=["time", "x", "y"])
    da_ppfd_aggregated = da_ppfd_aggregated["photosynthetic_photon_flux_density_W_m2"].to_dataframe(name = "PPFD") # * 0.5 # Wm-2 -> umolm-2s-1
    da_swp_aggregated = da_swp.groupby("time.year").mean(dim=["time", "x", "y"])
    da_swp_aggregated = da_swp_aggregated["soil_water_potential_MPa"].to_dataframe(name = "SWP_MPa")
    da_swp_aggregated["SWP_MPa"] = da_swp_aggregated["SWP_MPa"] * (-1)
    da_nr_aggregated = da_nr.groupby("time.year").mean(dim=["time", "x", "y"])
    da_nr_aggregated = da_nr_aggregated["net_absorbed_radiation_vegetation_MJ_m2_day"].to_dataframe(name = "NR_MJ_m2_day")

    print(da_vpd_aggregated)
    print(da_ppfd_aggregated)
    print(da_swp_aggregated)
    print(da_nr_aggregated)

    da_merge = pd.merge(da_T_aggregated, da_vpd_aggregated, left_index=True, right_index=True)
    da_merge = pd.merge(da_merge, da_ppfd_aggregated, left_index=True, right_index=True)
    da_merge = pd.merge(da_merge, da_swp_aggregated, left_index=True, right_index=True)
    da_merge = pd.merge(da_merge, da_nr_aggregated, left_index=True, right_index=True)

    outpath = Path(OUTPUT_DIR, "out_data_yearly.csv")
    print(outpath)
    da_merge.to_csv(outpath, index = True)


    print("grouping by day (spatial aggregate)")

    da_T_aggregated = da_temp.mean(dim=["x", "y"])
    da_T_aggregated = da_T_aggregated["temperature_K"].to_dataframe(name="temperature_C")
    da_T_aggregated["temperature_C"] = da_T_aggregated["temperature_C"] - 273.15  # K -> C
    da_vpd_aggregated = da_vpd.mean(dim=["x", "y"])
    da_vpd_aggregated = da_vpd_aggregated["vapour_pressure_deficit_kPa"].to_dataframe(name = "VPD_hPa")
    da_vpd_aggregated["VPD_hPa"] = da_vpd_aggregated["VPD_hPa"] * 10 # kPa -> hPa
    da_ppfd_aggregated = da_ppfd.mean(dim=["x", "y"])
    da_ppfd_aggregated = da_ppfd_aggregated["photosynthetic_photon_flux_density_W_m2"].to_dataframe(name = "PPFD") # * 0.5 # Wm-2 -> umolm-2s-1
    da_swp_aggregated = da_swp.mean(dim=["x", "y"])
    da_swp_aggregated = da_swp_aggregated["soil_water_potential_MPa"].to_dataframe(name = "SWP_MPa")
    da_swp_aggregated["SWP_MPa"] = da_swp_aggregated["SWP_MPa"] * (-1)
    da_nr_aggregated = da_nr.mean(dim=["x", "y"])
    da_nr_aggregated = da_nr_aggregated["net_absorbed_radiation_vegetation_MJ_m2_day"].to_dataframe(name = "NR_MJ_m2_day")

    print(da_vpd_aggregated)
    print(da_ppfd_aggregated)
    print(da_swp_aggregated)
    print(da_nr_aggregated)

    da_merge = pd.merge(da_T_aggregated, da_vpd_aggregated, left_index=True, right_index=True)
    da_merge = pd.merge(da_merge, da_ppfd_aggregated, left_index=True, right_index=True)
    da_merge = pd.merge(da_merge, da_swp_aggregated, left_index=True, right_index=True)
    da_merge = pd.merge(da_merge, da_nr_aggregated, left_index=True, right_index=True)

    outpath = Path(OUTPUT_DIR, "out_data_daily.csv")
    print(outpath)
    da_merge.to_csv(outpath, index = True)


