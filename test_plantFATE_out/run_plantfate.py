import os
from datetime import datetime
from pathlib import Path
import numpy as np
import pandas as pd
import random

from pypfate import Patch as patch


def process_time_units(plantFATE_model):
    time_unit = plantFATE_model.config.time_unit
    time_unit = time_unit.split()
    if time_unit[0] != "days" or time_unit[1] != "since":
        raise ValueError(
            "incorrect plantFATE time unit; cwatm coupling supports only daily timescale"
        )
    time_unit = time_unit[2].split("-")
    return datetime(int(time_unit[0]), int(time_unit[1]), int(time_unit[2]))

simulation_list_out = "data/plantFATE_rerun_data/simulation_list.csv"
simulation_list = []
num_sims_per_setting = 10

if os.path.exists(simulation_list_out):
    simulation_list = pd.read_csv(simulation_list_out)
else:
    biodiversity = ["lb", "hb"]
    new_forest = [True, False]
    afforestation_new_fn = "data/afforestation_new_10_cells.csv"
    afforestation_fn = "data/afforestation_10_cells.csv"
    afforestation_new = pd.read_csv(afforestation_new_fn)
    afforestation = pd.read_csv(afforestation_fn)

    forest_cells_existing = afforestation.cell[random.sample(afforestation.index.to_list(), num_sims_per_setting)]
    forest_cells_new = afforestation_new.cell[random.sample(afforestation_new.index.to_list(), num_sims_per_setting)]

    simulation_list = pd.DataFrame(data = {"biodiversity" : biodiversity * (num_sims_per_setting * 2),
                                           "new_forest" : np.concat([np.repeat(True, num_sims_per_setting * 2), np.repeat(False, num_sims_per_setting * 2)]),
                                           "cell" : np.concat([np.repeat(forest_cells_new, 2),
                                                               np.repeat(forest_cells_existing, 2)])})
    simulation_list.to_csv(simulation_list_out, index=False)

print(simulation_list)


for index_s, row_s in simulation_list.iterrows():
    # if index_s >= 1:
    #     continue

    ### Set up cell
    cell_id = row_s['cell']
    new_cell = row_s['new_forest']
    biodiv = row_s['biodiversity']

    if biodiv == "hb":
        continue

    print(index_s)
    print(row_s)
    print(biodiv)



    ### Find correct environment file
    # once hb 10 is processed for new cells need to make this variable for those
    env_input_fn = "data/" + "plantFATE_rerun_data/" "GEB_step4_" + biodiv + "_af_10/" + "env_data_cell_" + str(cell_id) + ".csv"
    env_input = pd.read_csv(env_input_fn)
    #
    # ### Find correct parameter file
    param_file_div = "data/plantFATE_rerun_data/settings"
    if biodiv == "lb":
        param_file_div = "data/plantFATE_rerun_data/settings/low_biodiversity"
    else:
        param_file_div = "data/plantFATE_rerun_data/settings/high_biodiversity"

    param_file = param_file_div
    if new_cell:
        param_file = str(param_file_div + "/p_new_forest.ini")
    else:
        param_file = str(param_file_div  + "/p_run.ini")

    print(param_file)

    plantFATE_model = patch(str(param_file))

    print(plantFATE_model.config.time_unit)
    time_unit_base = process_time_units(plantFATE_model)

    print("BEFORE EDITS")
    print("Continue from state file:")
    print(plantFATE_model.config.continueFrom_stateFile)
    print("Continue from config file:")
    print(plantFATE_model.config.continueFrom_configFile)
    print("Output directory:")
    print(plantFATE_model.config.out_dir)
    print("Experiment directory:")
    print(plantFATE_model.config.expt_dir)
    print("Traits file:")
    print(plantFATE_model.config.traits_file)

    # ### Set up output information

    out_dir = Path("out/PlantFATE_reruns_out/individual_cell_simulations/GEB_step4_" + biodiv + "_af_10")
    out_dir.mkdir(parents=True, exist_ok=True)
    expt_name = f"cell_{cell_id}_{biodiv}"  # expt name - results will be stored in outDir/exptName

    plantFATE_model.config.out_dir = out_dir.as_posix()
    plantFATE_model.config.expt_dir = expt_name
    # pfModel.plantFATE_model.config.save_state = False
    #
    # ### Make sure to get correct continue from previous information
    #
    if new_cell:
        plantFATE_model.config.continuePrevious = False
    else:
        plantFATE_model.config.continuePrevious = True
        directory = Path(str("data/plantFATE_rerun_data/GEB_step3_plantfate_" + biodiv + "_spinup/plantFATE/") + f"cell_{cell_id}" )
        plantFATE_model.config.continueFrom_stateFile = str(Path(directory / "pf_saved_state.txt"))
        plantFATE_model.config.continueFrom_configFile = str(Path(directory /"pf_saved_config.ini"))

    #update traits file

    traits_file = param_file_div + "/traits_plants.csv"
    plantFATE_model.config.traits_file = traits_file

    print("AFTER EDITS")
    print("Continue from state file:")
    print(plantFATE_model.config.continueFrom_stateFile)
    print("Continue from config file:")
    print(plantFATE_model.config.continueFrom_configFile)
    print("Output directory:")
    print(plantFATE_model.config.out_dir)
    print("Experiment directory:")
    print(plantFATE_model.config.expt_dir)
    print("Traits file:")
    print(plantFATE_model.config.traits_file)


    # #### RUN PLANTFATE

    # ### Run First Step
    # #
    tcurrent = 0

    tstart = env_input.Date.iloc[0]
    tstart = tstart.split("-")
    tstart = datetime(int(tstart[0]), int(tstart[1]), int(tstart[2]))

    datestart = datetime(tstart.year, tstart.month, tstart.day)
    datediff = datestart - time_unit_base
    datediff = datediff.days - 1

    print("Running first step")

    i = 0
    tcurrent = datediff

    plantFATE_model.init(datediff, datediff + 1000)
    plantFATE_model.reset_time(datediff)

    print("Running first step - after init")

    plantFATE_model.update_climate(
        368.9,
        env_input.Temp.iloc[i],
        env_input.VPD.iloc[i] * 100,
        env_input.PAR.iloc[i],
        env_input.SWP.iloc[i] * (-1),
        0,
    )


    print("Run steps")
    print(env_input.shape[0])
    tcurrent = tcurrent + 1

    while i < env_input.shape[0]:
    #env_input.size(dim=0)
        plantFATE_model.update_climate(
                368.9,
                env_input.Temp.iloc[i],
                env_input.VPD.iloc[i] * 100,
                env_input.PAR.iloc[i],
                env_input.SWP.iloc[i] * (-1),
                0,
            )
        plantFATE_model.simulate_to(tcurrent)
        i = i+1
        tcurrent = tcurrent + 1

    plantFATE_model.close()


