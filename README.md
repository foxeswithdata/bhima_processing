# bhima_processing

Analysis and figure code for Stefaniak et al., *GEB-PlantFATE v1.0: Coupling of forest demographic and soil hydrological models for simulating the hydrological impacts of afforestation and biodiversity*.

This repository processes the raw GEB-PlantFATE model output archived at [10.5281/zenodo.18457345](https://doi.org/10.5281/zenodo.18457345) and produces the figures in the paper. It contains code and one small spatial file; all model output must be downloaded separately from the data archive.

**Code DOI:** [WILL BE ADDED ON PUBLICATION]
**Data DOI:** [10.5281/zenodo.18457345](https://doi.org/10.5281/zenodo.18457345)
**Paper DOI:** [WILL BE ADDED ON PUBLICATION]

---

## 1. Citation

> Stefaniak, E. Z., Joshi, J., Artuso, S., Maxwell, T. L., Smilovic, M., Hofhansl, F., and de Bruijn, J. A. (2026). bhima_processing: analysis code for GEB-PlantFATE v1.0 afforestation scenarios [Software]. Zenodo. doi:[DOI]

Authors, affiliations and ORCIDs as listed in the data archive record.

---

## 2. What this code does

The pipeline takes daily GEB-PlantFATE output for twelve afforestation and biodiversity scenarios in the Ghod subbasin (Maharashtra, India) and produces catchment-scale aggregates, spatial diagnostics, and the publication figures. Stages:

1. **Setup and preprocessing** — generate scenario configuration files, build afforestation cell lists, derive current-forest polygons
2. **Aggregation** — reduce daily gridded Zarr output to basin-wide time series, spatial averages, and yearly and rolling summaries
3. **PlantFATE diagnostics** — extract per-cell environmental forcing and re-run PlantFATE for individual cells to inspect stand-level behaviour
4. **Figures** — one script per publication figure

Both R and Python are used. R handles most time-series processing and plotting; Python handles Zarr access, spatial work, and map production. Two Google Earth Engine JavaScript files export biomass reference layers and are run in the GEE code editor, not locally.

```
code/
├── figures_publication/    # one script per figure
├── google_earth_engine/    # GEE export scripts
├── util/                   # cell-list generation, zarr helpers
└── *.R, *.py               # preprocessing, aggregation, diagnostics
data/
└── maps/region.gpkg        # study area boundary
```

---

## 3. Setup

### Python

Managed with [uv](https://docs.astral.sh/uv/); Python ≥ 3.13.

```bash
uv sync
```

Dependencies: `xarray`, `zarr`, `rioxarray`, `netcdf4`, `geopandas`, `cartopy`, `matplotlib`, `cmcrameri`.

### R

Open `bhima_processing.Rproj` in RStudio. Required packages:

`tidyverse`, `sf`, `terra`, `raster`, `lubridate`, `zoo`, `ggpubr`, `scico`, `fmsb`, `gtools`, `yaml`, `inborutils`

```r
install.packages(c("tidyverse", "sf", "terra", "raster", "lubridate",
                   "zoo", "ggpubr", "scico", "fmsb", "gtools", "yaml"))
# inborutils is not on CRAN:
# remotes::install_github("inbo/inborutils")
```

R version used: [ADD]

**Run all scripts from the repository root**, not from `code/`. Run `.Rmd` files from their directory.

---

## 4. Getting the data

Download from Zenodo (doi:10.5281/zenodo.18457345) and extract as follows:

| Archive | Extract to |
|---|---|
| `GEB_step3_*.tar.gz`, `GEB_step4_*.tar.gz` | `data/ssp3_out/` |
| `GEB_step4_additional_data.zip` | `data/` |
| `step2_plantfate_spinup.tar.gz` | `data/` (creates `data/spinup/`) |
| `plantfate_reruns.tar.gz` | `data/` (creates `data/plantfate_reruns/`) |
| `maps.tar.gz` | `data/` (merges into `data/maps/`) |

```bash
mkdir -p data/ssp3_out out
for f in GEB_step3_*.tar.gz GEB_step4_*_af_*.tar.gz GEB_step4_default.tar.gz; do
  tar -xzf "$f" -C data/ssp3_out/
done
unzip GEB_step4_additional_data.zip -d data/
tar -xzf step2_plantfate_spinup.tar.gz -C data/
tar -xzf plantfate_reruns.tar.gz -C data/
tar -xzf maps.tar.gz -C data/
```

`ssp3.tar.gz` is not needed for the analysis — it is the runnable model directory, for reproducing the simulations themselves.

### Not included anywhere

Figure A2 uses relative density and dominance tables from appendices 3 and 4 of Jezeera (2016). These remain the copyright of the author and are not redistributed. To reproduce that figure, obtain the thesis (http://dr.iiserpune.ac.in:8080/xmlui/handle/123456789/594), extract the two tables, and save them as:

```
data/asmi_2016_thesis_data/appendix3_relative_density.csv
data/asmi_2016_thesis_data/appendix4_relative_dominance.csv
```

GEB step 1 environmental forcing (`data/prepare_plantfate_spinup/`) is also not archived. It is regenerable by running `model_resist_step1.yml` from `ssp3.tar.gz` with GEB v0.4, and is needed only to reproduce the PlantFATE spinup from scratch — the spinup output itself is archived.

---

## 5. Running the pipeline

Intermediate and final outputs are written to `out/`, which is not tracked.

| Stage | Scripts |
|---|---|
| Configuration | `generate_ymls.R`, `util/make_cell_list.R`, `make_PF_rerun_list.R` |
| Spatial setup | `create_current_forest_polygons.R`, `process_ghod_map.Rmd`, `subset_maps.py`, `area_data.py` |
| Aggregation | `prepare_averages_step3.py`, `prepare_averages_step4.py`, `prepare_sums_step4.py`, `prepare_basin_wide_step4.py`, `yearly_summary.py` |
| Time series | `process_step3_time_series.R`, `process_step4_time_series.R`, `process_one_to_one_basinwide.R`, `analyze_spinup_output.R` |
| PlantFATE diagnostics | `process_output_environment_data_prepare_cell_data.py`, `process_output_environment_data.py`, `run_plantfate.py`, `plot_plantfate_outputs.R`, `explore_plantfate_reruns.R` |
| Maps | `create_maps.py`, `make_maps_extra.R` |
| Figures | `figures_publication/figure_*.R`, `figures_publication/figure_*.py` |


### Figure scripts

| Figure | Script | Requires |
|---|---|---|
| 3 | `figure_3.R` (alt: `figure_3_alt.R`) | `out/ssp3_preproc` |
| 6 | `figure_6.py` | `data/ssp3_out`, additional data, maps |
| 7 | `figure_7.R` | `out/ssp3` |
| 8 | `figure_8.R` | `out/ssp3` |
| 9 | `figure_9.R` | `out/ssp3` |
| A2 | `figure_a2.R` | Jezeera (2016) tables — not redistributed |
| A3 | `figure_a3.R` | `data/spinup` |
| A4 | `figure_a4.R` | `out/environmental_data_processed` |
| A5 | `figure_a5.py` | `data/ssp3_out`, additional data, maps |
| A6 | `figure_a6.py` | `data/ssp3_out`, maps |
| A7 | `figure_a7.R` | `data/ssp3_out` |
| A9–A13 | `figure_a9.R` … `figure_a13.R` | `plantfate_reruns`, PlantFATE re-run outputs (see §6) |

Figures 1, 2, 4, 5, 10, A1 and A8 are not produced by scripts here. 

Figures A9–A13 depend on single-cell PlantFATE re-runs. The archived `individual_cell_simulations/` outputs are inputs to these figures; re-running them requires `run_plantfate.py` and a working PlantFATE installation.

---

## 6. Known issues

**Doubled unit suffix.** The archived store `soil_layer_forest_height_m.zarr` contains a data variable named `soil_layer_forest_height_m_m`. Scripts open the file by its single-`_m` name and read the variable by its doubled name; this asymmetry is intentional and matches the archive.

**`process_ghod_map.Rmd` uses paths relative to `code/`.** R Markdown knits relative to the document's own directory, so this file uses `../data` and `../out` while every other script uses paths relative to the repository root.

**Re-run output location.** Figures A9–A13 read PlantFATE re-run outputs from `out/PlantFATE_reruns_out/individual_cell_simulations/`, while the archive provides them at `data/plantfate_reruns/individual_cell_simulations/`. Copy or symlink them to the expected location before running those figures.

**No dependency lockfile for R.** Python is pinned via `uv.lock`; R packages are not. Consider `renv`.

---

## 7. Related resources

| Component | Location |
|---|---|
| Model output | doi:10.5281/zenodo.18457345 |
| GEB | v0.4, doi:10.5281/zenodo.22094305 — https://github.com/GEB-model/GEB |
| PlantFATE | [DOI PENDING] — https://github.com/jaideep777/Plant-FATE |
| GEB documentation | https://docs.geb.sh/ |

---

## 8. Funding

International Institute for Applied Systems Analysis (IIASA), Strategic Initiatives Program — projects **RESIST** and **FairStream**.

---

## 9. Licence

GNU General Public License v3.0. See `LICENSE`.

---

*This documentation was drafted with the assistance of an AI language model and reviewed and corrected by the authors.*
