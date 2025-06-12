# code to pre-process outputs from the GEB spinup and model run, written with the help of ChatGPT
# input: zarr files which are outputs from GEB (these are located in the p-drive - need to mount the drive)
# output: csv files summarizing all cells (mean, median, stdev, and 95% CI) for each time step 
# 12.06.2025

# code to mount pdrive sudo mount -t cifs -o vers=3.0,credentials=/home/maxwell/.smbcred_ictguest //pdrive.iiasa.ac.at/share/link/maxwell.pdrv /mnt/pdrive
# need to create a credential file .smbcred_ictguest with 
# username=maxwell
# password=PASSWORD
# domain=iiasa2003

import zarr
import numpy as np
import os
import pandas as pd
cwd = os.getcwd()
print(cwd)


# note: have not yet made this modularized so I just copy-pasted the code for soil moisture and replaced with transpiration

################################################### SOIL MOISTURE ###################################################

# Path to your .zarr directory
zarr_folder_path = '/mnt/pdrive/resist/bhima-basin/sanctuary_plantfate_may_21/output/report/spinup/hydrology.soil/soil_moisture_forest_m.zarr'

# Ensure the path exists
if not os.path.exists(zarr_folder_path):
    raise FileNotFoundError(f"The folder {zarr_folder_path} does not exist.")

# Open the Zarr dataset
z = zarr.open(zarr_folder_path, mode='r')  # 'r' means read-only

# Display the metadata
print("Zarr metadata:")
print(z.info)

# Check if this is a group
if isinstance(z, zarr.Group):
    print("\nAvailable arrays in the group:")
    for name, array in z.arrays():
        print(f"- {name}: shape={array.shape}, dtype={array.dtype}")


# Extract arrays
soil = z['soil_moisture_forest_m'][:]  # (time, y, x)
time = z['time'][:]
y = z['y'][:]
x = z['x'][:]

# Create meshgrid of coordinates
T, Y, X = np.meshgrid(time, y, x, indexing='ij')  # same shape as soil

# Flatten all arrays
flat_data = {
    'time': T.ravel(),
    'y': Y.ravel(),
    'x': X.ravel(),
    'soil_moisture_forest_m': soil.ravel()
}

# Convert to DataFrame
df = pd.DataFrame(flat_data)

# # Save to CSV
# df.to_csv('data/spinup/test/processed/soil_moisture.csv', index=False)
# print("CSV export complete: 'soil_moisture.csv'")

# 1. Total number of rows
total_rows = len(df)
print(f"Total rows: {total_rows}")

# 2. Number of rows with missing (NaN) values in 'soil_moisture_forest_m'
missing_rows = df['soil_moisture_forest_m'].isna().sum()
print(f"Rows with missing soil moisture values: {missing_rows}")

# 3. Filter out rows with missing soil moisture values
df_clean = df.dropna(subset=['soil_moisture_forest_m'])

# Optional: confirm new size
print(f"Remaining rows after dropping missing values: {len(df_clean)}")

# df_clean.to_csv('data/spinup/test/processed/soil_moisture_clean.csv', index=False)
# print("CSV export complete: 'soil_moisture_clean.csv'")


# Group and calculate stats
def compute_ci(x, confidence=0.95):
    n = len(x)
    if n == 0:
        return np.nan
    mean = np.mean(x)
    std_err = np.std(x, ddof=1) / np.sqrt(n)
    margin = 1.96 * std_err  # 95% CI for normal dist
    return pd.Series({
        'mean': mean,
        'median': np.median(x),
        'std': np.std(x, ddof=1),
        'ci_lower': mean - margin,
        'ci_upper': mean + margin
    })

agg_df = df_clean.groupby('time')['soil_moisture_forest_m'].apply(compute_ci).reset_index()

# Save to CSV
agg_df.to_csv('data/spinup/test/processed/soil_moisture_stats_by_time.csv', index=False)
print("Saved: soil_moisture_stats_by_time.csv")


################################################### TRANSPIRATION ###################################################
# Path to your .zarr directory
zarr_folder_path = '/mnt/pdrive/resist/bhima-basin/sanctuary_plantfate_may_21/output/report/spinup/hydrology.soil/transpiration_forest_m.zarr'

# Ensure the path exists
if not os.path.exists(zarr_folder_path):
    raise FileNotFoundError(f"The folder {zarr_folder_path} does not exist.")

# Open the Zarr dataset
z = zarr.open(zarr_folder_path, mode='r')  # 'r' means read-only

# Display the metadata
print("Zarr metadata:")
print(z.info)

# Check if this is a group
if isinstance(z, zarr.Group):
    print("\nAvailable arrays in the group:")
    for name, array in z.arrays():
        print(f"- {name}: shape={array.shape}, dtype={array.dtype}")


# Extract arrays
soil = z['transpiration_forest_m'][:]  # (time, y, x)
time = z['time'][:]
y = z['y'][:]
x = z['x'][:]

# Create meshgrid of coordinates
T, Y, X = np.meshgrid(time, y, x, indexing='ij')  # same shape as soil

# Flatten all arrays
flat_data = {
    'time': T.ravel(),
    'y': Y.ravel(),
    'x': X.ravel(),
    'transpiration_forest_m': soil.ravel()
}

# Convert to DataFrame
df = pd.DataFrame(flat_data)

# # Save to CSV
# df.to_csv('data/spinup/test/processed/transpiration.csv', index=False)
# print("CSV export complete: 'transpiration.csv'")

# 1. Total number of rows
total_rows = len(df)
print(f"Total rows: {total_rows}")

# 2. Number of rows with missing (NaN) values in 'transpiration_forest_m'
missing_rows = df['transpiration_forest_m'].isna().sum()
print(f"Rows with missing transpiration values: {missing_rows}")

# 3. Filter out rows with missing transpiration values
df_clean = df.dropna(subset=['transpiration_forest_m'])

# Optional: confirm new size
print(f"Remaining rows after dropping missing values: {len(df_clean)}")

# df_clean.to_csv('data/spinup/test/processed/transpiration_clean.csv', index=False)
# print("CSV export complete: 'transpiration_clean.csv'")


# Group and calculate stats
def compute_ci(x, confidence=0.95):
    n = len(x)
    if n == 0:
        return np.nan
    mean = np.mean(x)
    std_err = np.std(x, ddof=1) / np.sqrt(n)
    margin = 1.96 * std_err  # 95% CI for normal dist
    return pd.Series({
        'mean': mean,
        'median': np.median(x),
        'std': np.std(x, ddof=1),
        'ci_lower': mean - margin,
        'ci_upper': mean + margin
    })

agg_df = df_clean.groupby('time')['transpiration_forest_m'].apply(compute_ci).reset_index()

# Save to CSV
agg_df.to_csv('data/spinup/test/processed/transpiration_stats_by_time.csv', index=False)
print("Saved: transpiration_stats_by_time.csv")