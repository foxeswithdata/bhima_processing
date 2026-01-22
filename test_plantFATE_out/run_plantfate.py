from datetime import datetime
from pathlib import Path

import numpy as np
import pandas as pd
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



param_file = "p_run.ini"

plantFATE_model = patch(str(param_file))
time_unit_base = process_time_units(plantFATE_model)
tcurrent = 0

env_input_fn = "env_data_cell_2838.csv"
env_input = pd.read_csv(env_input_fn)

print(env_input.head())

plantFATE_model.config.continuePrevious = True
plantFATE_model.config.continueFrom_stateFile = str("pf_saved_state.txt")
plantFATE_model.config.continueFrom_configFile = str("pf_saved_config.ini")