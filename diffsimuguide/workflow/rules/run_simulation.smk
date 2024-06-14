import subprocess
import numpy as np
import os


out_dir = config['output_dir']
path = expand(inputs['dwi'].input_path,zip,**inputs['dwi'].input_zip_lists)
pathbval = re.sub(".nii.gz", ".bval",path[0])
pathbvec = re.sub(".nii.gz", ".bvec",path[0])
model = config["model"][0]

tmpdir=f"{out_dir}/tmpdir"
pathcollect = f'{tmpdir}/collect_done.txt'

rule run_diffusion_simulation: #uses DiffSimGen here
    input:
        bval = pathbval,  
        bvec = pathbvec,
        #connect = pathcollect
    params:
        numofsim = config["numofsim"],
        paramdist = config["parameter_distributions"],
        SNR = config["SNR"],
        model = config["model"]
#    log:
#        log = bids(root="logs", suffix="diffusion_simulation.log", **inputs.input_wildcards["dwi"]),
    output:
        #simulated_signals=expand(
        #    bids(
        #        root="work",
        #        suffix="simulated_signals_{model}.pkl",
        #        datatype="dwi",
        #        **inputs.input_wildcards["dwi"],
        #        ),
        #        model=config["model"],allow_missing=True
        #    ),
        simulated_signals = os.path.join(out_dir,f"simulated_signals_{model}.pkl"),
        #done2 = touch(temp(os.path.join(out_dir,f"done2.txt")))
    group:
        "subj"
    script:
        "../scripts/run_simulation.py"

#pathcollect2 = f'{tmpdir}/collect_done2.txt'

#rule collect_done2:
#    input:
 #       done = expand(rules.run_diffusion_simulation.output.done2,zip,**inputs.input_wildcards["dwi"]),
  #  output:
   #     collect2 = pathcollect2,
    #shell:
     #   "cat {input.done} > {output.collect2}"