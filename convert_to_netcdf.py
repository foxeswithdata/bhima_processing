import xarray as xr
import zarr

fpath_zarr = "data/ssp3_out/GEB_step3_default_spinup/hydrology.routing/discharge_daily_m3_s.zarr"

ds_from_zarr = xr.open_zarr(store=fpath_zarr, consolidated = False)

ds_from_zarr.to_netcdf("ds_zarr_to_nc.nc", encoding= {"rainrate":{"zlib":True}})