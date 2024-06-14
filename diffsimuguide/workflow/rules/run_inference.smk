import subprocess
import numpy as np
import os

out_dir = config['output_dir']
path = expand(inputs['dwi'].input_path,zip,**inputs['dwi'].input_zip_lists)
pathbval = re.sub(".nii.gz", ".bval",path[0])
model = config["model"][0]
QCdir=f"{out_dir}/QC"     
logdir = f"{out_dir}/logs"  

if not os.path.isdir(QCdir):           
    subprocess.call(['mkdir', QCdir])

if not os.path.isdir(logdir):           
    subprocess.call(['mkdir', logdir])

tmpdir=f"{out_dir}/tmpdir"
pathcollect = f'{tmpdir}/collect_done.txt'

rule run_inference: #uses uGUIDE here
    input:
        #simulated_signals=expand(
        #    bids(
        #        root="work",suffix="simulated_signals_{model}.pkl",
        #        **inputs.input_wildcards["dwi"],
        #        ),
        #        model=config["model"],allow_missing=True
        #    ),
        simulated_signals = os.path.join(out_dir,f"simulated_signals_{model}.pkl"),
        bval = pathbval,
        #connect = pathcollect
    params:
        numoffeatures = config["numoffeatures"],
        QC = config["no_QC"],
        model = config["model"][0],
    log:
        #log = expand(
        #    bids(
        #        root="logs", 
        #        suffix="run_inference_{model}.log", 
        #        datatype="dwi",
        #        **inputs.input_wildcards["dwi"],
        #        ),
        #        model=config["model"],allow_missing=True
        #    ) 
        log = os.path.join(logdir,f"run_inference_{model}.log"),      
    output:
        #MLP=expand(
        #    bids(
        #        root="work",
        #        suffix="torch_embedder_{model}.pt",
        #        datatype="dwi",
        #        **inputs.input_wildcards["dwi"],
        #        ),
        #        model=config["model"],allow_missing=True
        #    ),
        MLP = os.path.join(out_dir,f"torch_embedder_{model}.pt"),
        #normalize_flow=expand(
        #    bids(
        #        root="work",
        #        suffix="torch_nf_{model}.pt",
        #        datatype="dwi",
        #        **inputs.input_wildcards["dwi"],
        #        ),
        #        model=config["model"],allow_missing=True
        #    ),
        normalize_flow = os.path.join(out_dir,f"torch_nf_{model}.pt"),
        #uGUIDE_config=expand(
        #    bids(
        #        root="work",
        #        suffix="config_{model}.pkl",
        #        datatype="dwi",
        #        **inputs.input_wildcards["dwi"],
        #        ),
        #        model=config["model"],allow_missing=True
        #    ),
        uGUIDE_config = os.path.join(out_dir,f"config_{model}.pkl"),
        #QC = bids(
        #        root="QC",
        #        suffix="Spherical_Mean_Signal.png",
        #        **inputs.input_wildcards["dwi"]
        #),
        QC=os.path.join(out_dir,"QC","Spherical_Mean_Signal.png"),
    group:
        "subj"
    script:
        "../scripts/run_inference.py"