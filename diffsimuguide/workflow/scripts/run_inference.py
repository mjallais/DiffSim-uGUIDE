import numpy as np
import pandas as pd
from uGUIDE.config_utils import create_config_uGUIDE, save_config_uGUIDE
from uGUIDE.data_utils import preprocess_data
from uGUIDE.inference import run_inference
from uGUIDE.estimation import estimate_microstructure
from diffsimgen.scripts import generate_training_data
import os

signal_dict = snakemake.input.simulated_signals
model = snakemake.params.model
numoffeatures = snakemake.params.numoffeatures
bvals = snakemake.input.bval
QC = ~snakemake.params.QC

with open(signal_dict, "rb") as fp:
    # Load the model dictionary from the file
    signal_dict = pickle.load(fp)

theta_train = signal_dict['parameters']
x_train = signal_dict['signal']

theta_train, x_train = preprocess_data(theta_train, x_train, bvals, summ_stats=True)

pathname = os.path.dirname(generate_training_data.__file__)
with open(f'{pathname}/../../resources/{model}_parameter_range.json', 'r') as f:
    param_range = json.load(f)

#prior = {'f': [0.0, 1.0],
#         'Da': [0.1, 3.0],
#         'ODI': [0.03, 0.95],
#         'u0': [0.0, 1.0],
#         'u1': [0.0, 1.0]}

prior = param_range

config = create_config_uGUIDE(microstructure_model_name=model,
                              size_x=x_train.shape[1],
                              prior=prior,
                              folderpath=
                              use_MLP=True,
                              nf_features=numoffeatures,
                              max_epochs=1000,
                              n_epochs_no_change=30,
                              nb_samples=50_000,
                              random_seed=1234)

save_config_uGUIDE(config, savefile=snakemake.output.uGUIDE_config)

f = open(snakemake.log.log, "a")
f.write(f'Device used for computations: {config["device"]}')
f.close()

run_inference(theta_train, x_train, config=config,
              plot_loss=QC, load_state=False)


