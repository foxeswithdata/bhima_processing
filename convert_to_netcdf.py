import xarray as xr
import matplotlib.pyplot as plt
import matplotlib.axes as axs

fpath_zarr = "data/ssp3_out/GEB_step3_default_spinup/hydrology.soil/soil_moisture_forest_m.zarr"
# fpath_zarr = "data/prepare_plantfate_spinup/vapour_pressure_deficit_kPa.zarr"

print(fpath_zarr)
ds_from_zarr = xr.open_zarr(fpath_zarr, consolidated = False)

print(type(ds_from_zarr))
print(ds_from_zarr.dtypes)

print(ds_from_zarr.soil_moisture_forest_m)
print(dir(ds_from_zarr.soil_moisture_forest_m))

soil_moisture_forest = ds_from_zarr.soil_moisture_forest_m

smf_2d = soil_moisture_forest.isel(time=0)
fig = smf_2d.plot().figure
fig.savefig("soil-moisture-forest.png", dpi = 200)
# ds_from_zarr.to_netcdf("ds_zarr_to_nc.nc", encoding= {"rainrate":{"zlib":True}})

fig.clear()


fpath_zarr = "data/ssp3_out/GEB_step3_default_spinup/hydrology.soil/soil_water_potential_MPa.zarr"
# fpath_zarr = "data/prepare_plantfate_spinup/vapour_pressure_deficit_kPa.zarr"

print(fpath_zarr)
ds_from_zarr = xr.open_zarr(fpath_zarr, consolidated = False)

print(type(ds_from_zarr))
print((ds_from_zarr.dtypes))

print(ds_from_zarr.soil_water_potential_MPa)
print(dir(ds_from_zarr.soil_water_potential_MPa))

soil_moisture_forest = ds_from_zarr.soil_water_potential_MPa

smf_2d = soil_moisture_forest.isel(time=0)
fig = smf_2d.plot()
fig.figure.savefig("soil-water_potential.png", dpi = 200)
# ds_from_zarr.to_netcdf("ds_zarr_to_nc.nc", encoding= {"rainrate":{"zlib":True}})