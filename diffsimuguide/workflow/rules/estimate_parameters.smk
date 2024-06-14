import subprocess
import numpy as np
import os

out_dir = config['output_dir']
model = config["model"][0]
uGUIDE_config = os.path.join(out_dir,f"config_{model}.pkl"),
pathpkl = uGUIDE_config[0]

#with open(pathpkl, "rb") as fp:
    # Load the model dictionary from the file
#    simsignals = pickle.load(fp)

#nameofparams = simsignals['prior_postprocessing'].keys()

tmpdir=f"{out_dir}/tmpdir"
pathcollect = f'{tmpdir}/collect_done.txt'
#pathcollect2 = f'{tmpdir}/collect_done2.txt'


path = expand(inputs['dwi'].input_path,zip,**inputs['dwi'].input_zip_lists)
pathbval = re.sub(".nii.gz", ".bval",path[0])
pathbvec = re.sub(".nii.gz", ".bvec",path[0])


rule estimate_parameters: #Runs on real data here
    input:
        normalized_data=bids(
            root="work",
            suffix="dwi_normalized.nii.gz",
            datatype="dwi",
            **inputs.input_wildcards["dwi"]
        ),
        mask = re.sub("dwi.nii.gz", "brain_mask.nii.gz",inputs.input_path["dwi"]),
        MLP = os.path.join(out_dir,f"torch_embedder_{model}.pt"),
        normalize_flow = os.path.join(out_dir,f"torch_nf_{model}.pt"),
        uGUIDE_config = os.path.join(out_dir,f"config_{model}.pkl"),
        simulated_signals = os.path.join(out_dir,f"simulated_signals_{model}.pkl"),
        #connect = pathcollect,
        #connect2 = pathcollect2,
    params:
        tmpdir = tmpdir
    log:
        log = bids(root="logs", suffix="estimate_parameters.log", **inputs.input_wildcards["dwi"]),
    output:
        maps=expand(
            bids(
                root="results",suffix="{metric}.nii.gz",desc="uGUIDE",**inputs.input_wildcards["dwi"]
                ),
                metric=config[f'{model}_params'],allow_missing=True
            ),    
        image_map=bids(
            root="results",
            suffix=f"output_index.txt",
            **inputs.input_wildcards["dwi"]
        ),
    group:
        "subj"
    script:
        "../scripts/estimate_parameters.py"