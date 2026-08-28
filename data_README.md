# GEB-PlantFATE v1.0 — Afforestation scenario outputs, Ghod subbasin, India

Model output and configuration for the simulations reported in Stefaniak et al., *GEB-PlantFATE v1.0: Coupling of forest demographic and soil hydrological models for simulating the hydrological impacts of afforestation and biodiversity*.

**Record DOI:** [10.5281/zenodo.18457345](https://doi.org/10.5281/zenodo.18457345)
**Paper DOI:** [PENDING]
**Analysis code:** https://github.com/foxeswithdata/bhima_processing — [DOI PENDING]

---

## 1. Citation

> Stefaniak, E. Z., Joshi, J., Artuso, S., Maxwell, T. L., Smilovic, M., Hofhansl, F., and de Bruijn, J. A. (2026). GEB-PlantFATE v1.0: Coupling of forest demographic and soil hydrological models for simulating the hydrological impacts of afforestation and biodiversity. [JOURNAL], doi:[DOI] [PENDING]

> Stefaniak, E. Z., Joshi, J., Artuso, S., Maxwell, T. L., Smilovic, M., Hofhansl, F., and de Bruijn, J. A. (2026). Model outputs: GEB-PlantFATE v1.0 afforestation scenarios, Ghod subbasin, India [Data set]. Zenodo. doi:10.5281/zenodo.18457345

### Authors

| | Author | Affiliation | ORCID |
|---|---|---|---|
| 1 | Elisa Z. Stefaniak | IIASA (1) | 0000-0003-2998-5619 |
| 2 | Jaideep Joshi | IIASA (2); IIT Bombay (3); OIST (4) | 0000-0003-1315-6234 |
| 3 | Silvia Artuso | IIASA (5) | 0000-0001-5428-4860 |
| 4 | Tania L. Maxwell | IIASA (1); Université Paris-Saclay (6) | 0000-0002-8413-9186 |
| 5 | Mikhail Smilovic | IIASA (5) | 0000-0001-9651-8821 |
| 6 | Florian Hofhansl | IIASA (1) | 0000-0003-0073-0946 |
| 7 | Jens A. de Bruijn | IIASA (5); VU Amsterdam (7) | 0000-0003-3961-6382 |

Hofhansl and de Bruijn are joint senior authors.

1. Biodiversity, Ecology and Conservation Group, Biodiversity and Natural Resources Program, International Institute for Applied Systems Analysis (IIASA), Laxenburg 2361, Austria
2. Advancing Systems Analysis Program, IIASA, 2361 Laxenburg, Austria
3. Centre for Climate Studies, Indian Institute of Technology Bombay, Mumbai 400076, India
4. Complexity Science and Evolution Unit, Okinawa Institute of Science and Technology Graduate University, Onna, Okinawa 904-0495, Japan
5. Water Security Research Group, Biodiversity and Natural Resources Program, IIASA, Laxenburg 2361, Austria
6. Université Paris-Saclay, CNRS, AgroParisTech, Ecologie Systématique et Evolution, Gif-sur-Yvette, France
7. Institute for Environmental Studies, VU University, De Boelelaan 1087, 1081HV, Amsterdam, The Netherlands

---

## 2. Study area and design

A 628 km² section of the Ghod subbasin, Pune District, Maharashtra, India — Upper Bhima basin, within the Krishna basin, on the eastern flank of the Northern Western Ghats. Sub-tropical, semi-arid to sub-humid, with around 85% of rainfall arriving with the South-West monsoon between June and mid-October. About 18% of the area is currently forested. A further 18% (118 km²) is eligible for return to tribal communities under the Indian Forest Rights Act and forms the candidate area for afforestation.

Twelve simulations, from three model setups across six afforestation levels:

| Code | Meaning |
|---|---|
| `hb` | GEB-PlantFATE, high biodiversity (10 species) |
| `lb` | GEB-PlantFATE, low biodiversity (1 species) |
| `default` | GEB hydrology only, no PlantFATE (unforested case only) |
| `af_00` … `af_10` | 0, 20, 40, 60, 80, 100% of potential FRA area afforested |
| `step3` | Spinup, 1990–2020 |
| `step4` | Scenario, 2020–2049 |

Each afforestation level is a single random realisation drawn from the potential FRA area.

**On the count of twelve.** Thirteen `step4` archives are present, but `hb_af_00` and `lb_af_00` are substantively identical: the spinup initialises all existing mature forest as high-biodiversity regardless of scenario, so with no new afforestation the two biodiversity treatments converge. The biodiversity contrast therefore tests the composition of *newly established* forest against a fixed mature-forest background. Both runs are archived for completeness; count them as one.

---

## 3. Forcing and inputs

| Input | Source |
|---|---|
| Climate forcing | ISIMIP3b, GFDL-ESM4, SSP3-7.0 (Frieler et al., 2024) |
| CO₂ concentrations | Meinshausen et al. (2020), historical + SSP3-7.0 |
| Reservoirs | HydroLAKES (Messager et al., 2016) |
| Land use | ESA WorldCover 2021, 10 m, downscaled to 1.5″ |
| Soil texture | SoilGrids (Poggio et al., 2021) |
| Soil hydraulic properties | Derived via Rawls and Brakensiek (1989) |
| Plant traits | TRY database (Kattge et al., 2020) and supplementary sources |
| P50 values | Nearby site measurements (Sunny, 2020); global phylogenetic database (Knighton et al., 2025) |
| Species abundance | Jezeera (2016), appendices 3 and 4 — **not redistributed**, see §8 |
| FRA polygons | Maharashtra Forest Department, Government of India, 2023 |

PlantFATE uses four traits per species: wood density (ρ), xylem pressure at 50% loss of conductivity (P50), maximum height (Hmax), and leaf mass per area (LMA). Species are the ten most abundant recorded at the nearby Bhimashankar Wildlife Sanctuary. All other plant parameters take PlantFATE defaults.

---

## 4. Model configuration

**Active:** GEB hydrology; MODFLOW 6 groundwater; routing and reservoirs; PlantFATE (except `default` runs).
**Not active:** SFINCS hydrodynamic flood module.

**Agents run but do not decide.** Farmer and household agents are instantiated and stepped through the simulation, so their water demand enters the hydrology, but their decision-making is disabled. Agent behaviour is held fixed and identical across all twelve scenarios; these are not agent-based experiments, and differences between scenarios are attributable to afforestation and biodiversity alone.

| Property | Value |
|---|---|
| Spatial resolution | 30 arcseconds (~1 km at 19°N) |
| Grid | 78 (y) × 109 (x) |
| Extent | ~18.77–19.41°N, 73.54–74.44°E |
| Sub-grid | Hydrological Response Units, variable size, up to 100 per cell |
| Temporal resolution | Daily |
| Scenario period | 2020-01-01 to 2049-12-31 (10,958 steps) |
| Spinup period | 1990–2020 |

**No calibration or evaluation against observations was performed.** The paper is a model-description study; these outputs should not be treated as validated predictions for the Ghod subbasin.

**The grid is larger than the study area.** The 78 × 109 rectangle spans roughly 6,700 km², about ten times the 628 km² catchment. The catchment is masked within it and out-of-mask cells are NaN. Aggregating over the raw grid without applying the mask and cell-area weights will give badly wrong totals. Use `input/geom/mask.geoparquet` and `input/grid/cell_area.zarr` from `ssp3.tar.gz`.

### Model chain

```
GEB step 1  →  environmental forcing (5 Zarr stores)    NOT ARCHIVED — regenerable
     ↓
GEB step 2  →  PlantFATE spinup                          step2_plantfate_spinup.tar.gz
     ↓
GEB step 3  →  coupled spinup, 1990–2020                 GEB_step3_*.tar.gz
     ↓
GEB step 4  →  scenarios, 2020–2049                      GEB_step4_*.tar.gz
```

Step 1 output is not archived. It can be regenerated by running `model_resist_step1.yml` from `ssp3.tar.gz` with GEB v0.4, and is needed only to reproduce step 2 from scratch — step 2 results are archived directly.

---

## 5. Files

| File | Contents |
|---|---|
| `GEB_step4_default.tar.gz` | Scenario run, no PlantFATE |
| `GEB_step4_hb_af_{00,02,04,06,08,10}.tar.gz` | Scenario runs, high biodiversity |
| `GEB_step4_lb_af_{00,02,04,06,08,10}.tar.gz` | Scenario runs, low biodiversity |
| `GEB_step3_default_spinup.tar.gz` | Spinup, no PlantFATE |
| `GEB_step3_plantfate_hb_spinup.tar.gz` | Spinup, high biodiversity |
| `GEB_step3_plantfate_lb_spinup.tar.gz` | Spinup, low biodiversity |
| `GEB_step4_additional_data.zip` | Forest area, PlantFATE area, canopy height, per afforestation level |
| `step2_plantfate_spinup.tar.gz` | PlantFATE spinup output and GEB spinup diagnostics |
| `plantfate_reruns.tar.gz` | Per-cell PlantFATE re-runs, forcing, settings and cell lists |
| `maps.tar.gz` | Study region boundary and potential FRA area polygons |
| `ssp3.tar.gz` | Complete runnable model directory |
| `README.md` | This file |

Spinup and scenario archives share an identical internal structure. `default` archives omit all PlantFATE variables.

### Structure within a run archive

```
GEB_step4_hb_af_04/
├── hydrology.landcover/
│   └── runoff_weighted_mean_m.csv
├── hydrology.routing/
│   ├── discharge_daily_m3_s.zarr
│   └── discharge_daily.zarr
└── hydrology.soil/
    ├── biomass_forest_plantFATE.zarr
    ├── groundwater_recharge_forest_m.zarr
    ├── groundwater_recharge_plantfate_m.zarr
    ├── groundwater_recharge_weighted_mean_m.csv
    ├── net_absorbed_radiation_vegetation_MJ_m2_day.zarr
    ├── NPP_forest_plantFATE.zarr
    ├── photosynthetic_photon_flux_density_W_m2.zarr
    ├── soil_evaporation_forest_m.zarr
    ├── soil_evaporation_plantfate_m.zarr
    ├── soil_evaporation_weighted_mean_m.csv
    ├── soil_moisture_forest_m.zarr
    ├── soil_moisture_plantfate_m.zarr
    ├── soil_moisture_weighted_mean_m.csv
    ├── soil_water_potential_MPa.zarr
    ├── temperature_K.zarr
    ├── transpiration_forest_m.zarr
    ├── transpiration_plantfate_m.zarr
    ├── transpiration_weighted_mean_m.csv
    └── vapour_pressure_deficit_kPa.zarr
```

### `GEB_step4_additional_data.zip`

Afforested area is identical across the two biodiversity treatments at a given level, so these diagnostics are archived once per level:

```
GEB_step4_af_{00,02,04,06,08,10}/
└── hydrology.soil/
    ├── forest_area_m2.zarr
    ├── plantfate_area_m2.zarr
    └── soil_layer_forest_height_m.zarr
```

### `step2_plantfate_spinup.tar.gz`

Two unrelated groups. `spinup_PF/` is PlantFATE spinup output; `test/` is GEB spinup diagnostics.

```
spinup/
├── spinup_PF/
│   ├── D_PFATE.csv           # community-level output
│   ├── Y_mean_PFATE.csv      # species-level means
│   └── Y_PFATE_repl.csv      # species-level, non-breaking spaces removed
└── test/
    ├── groundwater_recharge_weighted_mean_m.csv
    ├── soil_evaporation_weighted_mean_m.csv
    ├── soil_moisture_weighted_mean_m.csv
    ├── transpiration_weighted_mean_m.csv
    ├── plots/
    └── processed/            # per-timestep statistics across cells
```

### `plantfate_reruns.tar.gz`

Single-cell PlantFATE re-runs used for figures A9–A13. Only the 100% afforestation cases were re-run.

```
plantfate_reruns/
├── cell_lists/                       # afforestation_{00..10}_cells.csv, afforestation_new_*
├── environmental_data/               # per-cell forcing, hb_af_10 and lb_af_10
├── individual_cell_simulations/      # PlantFATE output, hb_af_10 and lb_af_10
├── settings/
│   ├── co2_forcing.csv
│   ├── high_biodiversity/            # traits + PlantFATE configs and saved state
│   └── low_biodiversity/
├── simulation_list.csv               # cells selected for re-run
└── spinup_state/                     # step 3 PlantFATE saved state, per cell
```

**`simulation_list.csv` is not reproducible.** The cells were drawn at random without a fixed seed. Regenerating the list gives different cells and different figures; use the archived file.

### `maps.tar.gz`

```
maps/
├── region.gpkg                   # study area boundary
└── junnar_potential_CFR.gpkg     # potential FRA area
```

`junnar_potential_CFR.gpkg` also appears inside `ssp3.tar.gz`, which is a self-contained runnable model directory. The copy here is for analysis use; they are the same geometry.

### `ssp3.tar.gz`

```
sanctuary_plantfate_ssp3/
├── build.yml, model.yml, model_base.yml, resist_config.yml
├── model_job_1.yml … model_job_12.yml     # the twelve scenario specifications
├── model_resist_step{1,3,4}_*.yml
├── report_default.yml, report_plantfate.yml
├── run_geb_RESIST*.slurm
├── data/
│   ├── forest_{02,04,06,08,1}.gpkg        # afforestation realisations
│   ├── junnar_potential_CFR.gpkg
│   └── plantFATE/
├── generate_environment_step1/
├── generate_plantFATE_data_step2/
├── input/                                 # built GEB model input tree
└── simulation_root/spinup/                # MODFLOW model + agent store
```

There is no `forest_00.gpkg`: the 0% level involves no afforestation and therefore no layer.

---

## 6. Variables

### Naming convention

- `_forest_` — weighted sum across all forest outputs for each grid cell
- `_plantfate_` — weighted sum across PlantFATE forest outputs for each grid cell (under some circumstances default forest cells are used)
- `_weighted_mean_` — averaged across all land-cover types in the catchment

Units appear in the filename suffix. Note that `_forest_` and `_plantfate_` variables exist only as spatial Zarr stores, and `_weighted_mean_` variables only as aggregated CSV. There is no spatial weighted-mean field.

### Zarr stores (spatially distributed, daily)

| Variable | Units | Description |
|---|---|---|
| `discharge_daily_m3_s` | m³ s⁻¹ | River discharge |
| `biomass_forest_plantFATE` | kgC m⁻² | Forest biomass, PlantFATE |
| `NPP_forest_plantFATE` | kgC m⁻² day⁻¹ | Net primary productivity, PlantFATE |
| `groundwater_recharge_forest_m` | m | Groundwater recharge, forest fraction |
| `groundwater_recharge_plantfate_m` | m | Groundwater recharge, PlantFATE fraction |
| `soil_evaporation_forest_m` | m | Soil evaporation, forest fraction |
| `soil_evaporation_plantfate_m` | m | Soil evaporation, PlantFATE fraction |
| `soil_moisture_forest_m` | m | Soil moisture, forest fraction |
| `soil_moisture_plantfate_m` | m | Soil moisture, PlantFATE fraction |
| `transpiration_forest_m` | m | Transpiration, forest fraction |
| `transpiration_plantfate_m` | m | Transpiration, PlantFATE fraction |
| `soil_water_potential_MPa` | MPa | Soil water potential |
| `net_absorbed_radiation_vegetation_MJ_m2_day` | MJ m⁻² day⁻¹ | Net absorbed radiation by vegetation |
| `photosynthetic_photon_flux_density_W_m2` | W m⁻² | Photosynthetic photon flux density |
| `temperature_K` | K | Temperature |
| `vapour_pressure_deficit_kPa` | kPa | Vapour pressure deficit |

In `GEB_step4_additional_data.zip`:

| Variable | Units | Description |
|---|---|---|
| `forest_area_m2` | m² | Forest area per grid cell |
| `plantfate_area_m2` | m² | Area per grid cell simulated by PlantFATE |
| `soil_layer_forest_height_m` | m | Soil layer height under forest, used to convert soil moisture to volumetric units |

Note that inside `soil_layer_forest_height_m.zarr` the data variable is named `soil_layer_forest_height_m_m`, with a doubled unit suffix. The filename and the internal variable name therefore differ; code reading this store must use the doubled form.

Each store holds one variable with dimensions `(time, y, x)` = `(10958, 78, 109)`, dtype float32. Cells outside the catchment mask are NaN.

### CSV files (catchment-aggregated, daily)

Two columns — `date` (ISO 8601) and the named variable:

| File | Units |
|---|---|
| `runoff_weighted_mean_m.csv` | m |
| `groundwater_recharge_weighted_mean_m.csv` | m |
| `soil_evaporation_weighted_mean_m.csv` | m |
| `soil_moisture_weighted_mean_m.csv` | m |
| `transpiration_weighted_mean_m.csv` | m |

Example:

```
date,transpiration_weighted_mean_m
2020-01-01,0.00089263456
2020-01-02,0.00092400063
```

---

## 7. Loading the data

```python
import xarray as xr
import pandas as pd

ds = xr.open_zarr("GEB_step4_hb_af_04/hydrology.soil/transpiration_plantfate_m.zarr")
da = ds["transpiration_plantfate_m"]        # (time, y, x), NaN outside catchment

ts = da.mean(dim=["y", "x"], skipna=True)   # catchment mean
annual = da.resample(time="YE").sum(skipna=True)

df = pd.read_csv(
    "GEB_step4_hb_af_04/hydrology.soil/transpiration_weighted_mean_m.csv",
    parse_dates=["date"], index_col="date",
)
```

For area-weighted totals rather than means, weight by `input/grid/cell_area.zarr` from `ssp3.tar.gz` rather than taking a plain spatial mean.

---

## 8. Known issues and caveats

**Duplicate discharge output.** `discharge_daily_m3_s.zarr` and `discharge_daily.zarr` are the same output written twice, a consequence of the reporting configuration. Use either; they are not different quantities. Left in place because correcting it would require re-generating every archive.

**No validation.** These runs were not calibrated or evaluated against observed discharge, soil moisture, biomass, or evapotranspiration. See §4.

**Grid extent exceeds study area.** See §4 — apply the catchment mask before aggregating.

**Agent behaviour is fixed, not absent.** Agents run but make no decisions (see §4). The `input/array/agents/` tree and `simulation_root/spinup/store/agents.crop_farmers.var/` therefore contain populated farmer and household state, which may look like an active agent-based experiment. It is not.

**Species abundance data not redistributed.** Relative density and dominance tables are appendices 3 and 4 of Jezeera (2016) and remain the copyright of the author. They are cited but not included here or in the code repository. Figure A2 requires obtaining them from the thesis.

**Restricted data removed.** `IHDS_I.csv`, containing India Human Development Survey data, was present in the working model directory but has been removed: the IHDS is distributed under a data use agreement that does not permit redistribution. Model parameters derived from it during the build step remain in `input/`.

**Unused configuration present.** `input/dict/damage_parameters/flood/` and `input/dict/hydrodynamics/DEM_config.json` are part of the standard GEB input tree but play no role here, as the flood module is inactive.

**Re-runs cover only the 100% afforestation case.** `plantfate_reruns.tar.gz` contains `hb_af_10` and `lb_af_10` only.

**Doubled unit suffix inside one store.** `soil_layer_forest_height_m.zarr` holds a data variable named `soil_layer_forest_height_m_m`. The filename was corrected but the variable name inside the store was not, since doing so would require regenerating the archive. Read it with the doubled name.

---

## 9. Code

| Component | Repository | Archived version |
|---|---|---|
| GEB | https://github.com/GEB-model/GEB | v0.4, doi:10.5281/zenodo.22094305 |
| PlantFATE | https://github.com/jaideep777/Plant-FATE | [DOI PENDING] — commit [HASH] |
| Analysis and figures | https://github.com/foxeswithdata/bhima_processing | [DOI PENDING] |

GEB v0.4 is the release incorporating the PlantFATE coupling and is the version used for these runs.

GEB documentation: https://docs.geb.sh/

---

## 10. Funding

International Institute for Applied Systems Analysis (IIASA), Strategic Initiatives Program — projects **RESIST** and **FairStream**.

---

## 11. Licence

Model outputs and this documentation: Creative Commons Attribution 4.0 International (CC-BY-4.0).

Scripts contained within `ssp3.tar.gz` (`.py`, `.ipynb`, `.slurm`) are additionally covered by the licences of the repositories listed in §9 — GEB is distributed under GPL-3.0. Third-party input data retain the licences of their original sources as listed in §3.

---

## 12. References

- de Bruijn, J. A., Smilovic, M., Burek, P., Guillaumot, L., Wada, Y., and Aerts, J. C. J. H. (2023). GEB v0.1: a large-scale agent-based socio-hydrological model. *Geosci. Model Dev.* 16, 2437–2454. doi:10.5194/gmd-16-2437-2023
- de Bruijn, J. A., and Stefaniak, E. (2026). GEB: a large-scale agent-based socio-hydrological model, v0.4. Zenodo. doi:10.5281/zenodo.22094305
- Frieler, K., et al. (2024). ISIMIP3b bias-adjusted atmospheric climate input data. 
- Jezeera, A. M. (2016). Variation in plant functional traits across contrasting habitats in a seasonally dry tropical forest in the Northern Western Ghats. BS-MS dissertation, Department of Biology, Indian Institute of Science Education and Research (IISER) Pune, India. http://dr.iiserpune.ac.in:8080/xmlui/handle/123456789/594
- Kanade, R., Lohakare, K., Bhadbhade, N., Joy, K. J., Thomas, B. K., Martin, J., and Willaarts, B. (2023). Situational Analysis of the Upper Bhima sub-basin in the context of the Water-Food-Biodiversity Nexus. Zenodo. doi:10.5281/zenodo.8255959
- Kattge, J., et al. (2020). TRY plant trait database — enhanced coverage and open access. *Glob. Change Biol.* 26, 119–188.
- Knighton, J., et al. (2025). A Globally Comprehensive Database of Tree Hydraulic and Structural Traits Imputed from Phylogenetic Relationships. Zenodo. doi:10.5281/zenodo.15009207
- Meinshausen, M., et al. (2020). The shared socio-economic pathway (SSP) greenhouse gas concentrations and their extensions to 2500. *Geosci. Model Dev.* 13, 3571–3605.
- Messager, M. L., Lehner, B., Grill, G., Nedeva, I., and Schmitt, O. (2016). Estimating the volume and age of water stored in global lakes. *Nat. Commun.* 7, 13603.
- Poggio, L., et al. (2021). SoilGrids 2.0: producing soil information for the globe. *SOIL* 7, 217–240.
- Rawls, W. J., and Brakensiek, D. L. (1989). Estimation of soil water retention and hydraulic properties. 
- Sunny, R. (2020). Hydraulic traits in seasonally dry tropical forests. Integrated Ph.D. thesis, Department of Biology, Indian Institute of Science Education and Research (IISER) Pune, India. http://dr.iiserpune.ac.in:8080/xmlui/handle/123456789/6128

---

*This documentation was drafted with the assistance of an AI language model and reviewed and corrected by the authors.*
