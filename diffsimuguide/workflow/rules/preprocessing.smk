import subprocess
import numpy as np
import os

#if no brain mask provided make one 
#normalize data (check) if not normalize and save to work (normalize in mask)
#estimate noise if user didn't provide SNR

out_dir = config['output_dir']
tmpdir=f"{out_dir}/tmpdir"

#if inputs.input_path["brain_mask"] DOES NOT EXIST
#    rule run_BET: OR run dwi2mask or just use intensity masking
#        input:
#            noise_method = config["noise_method"]
#        #params:
#            #diravg = config["no_direction_averaging"],
#    log:
#        log = bids(root="logs", suffix="automatic_noise_estimation.log", **inputs.input_wildcards["dwi"]),
#    output:
#        SNR = config['SNR'],
#        SNRtxt = bids(root="work", suffix="SNR_estimation.txt", **inputs.input_wildcards["dwi"]),
#    group:
#        "subj"
#    script:
#        run_automatic_noise.py

rule normalize_data: #Runs on real data here
    input:
        dwi = inputs.input_path["dwi"],
        mask = re.sub("dwi.nii.gz", "brain_mask.nii.gz",inputs.input_path["dwi"]),       
        bval = re.sub(".nii.gz", ".bval",inputs.input_path["dwi"]),       
        bvec = re.sub(".nii.gz", ".bvec",inputs.input_path["dwi"]),
    #params:
        #FWHM = str(config["FWHM"]),
    log:
        log = bids(root="logs", suffix="normalize_data.log", **inputs.input_wildcards["dwi"]),
    output:
        normalized_data=bids(
            root="work",
            suffix="dwi_normalized.nii.gz",
            datatype="dwi",
            **inputs.input_wildcards["dwi"]
        ),
        done = touch(temp(bids(
                root="work",
                datatype="dwi",
                suffix="done.txt",
                **inputs.input_wildcards["dwi"]
            ),
        ),
        )
    group:
        "subj"
    script:
        "../scripts/normalize_data.py"

pathcollect = f'{tmpdir}/collect_done.txt'

rule collect_done:
    input:
        done = expand(rules.normalize_data.output.done,zip,**inputs['dwi'].input_zip_lists),
    output:
        collect = pathcollect,
    shell:
        "cat {input.done} > {output.collect}"

#if ~config["SNR"]:
#    rule run_automatic_noise:
#        input:
#            noise_method = config["noise_method"]
#        #params:
#            #diravg = config["no_direction_averaging"],
#    log:
#        log = bids(root="logs", suffix="automatic_noise_estimation.log", **inputs.input_wildcards["dwi"]),
#    output:
#        SNR = config['SNR'],
#        SNRtxt = bids(root="work", suffix="SNR_estimation.txt", **inputs.input_wildcards["dwi"]),
#    group:
#        "subj"
#    script:
#        run_automatic_noise.py

