import numpy as np
import pandas as pd
import time
import subprocess
from joblib import Parallel, delayed
import os
import uGUIDE.data_utils as du

mask = snakemake.input.mask
dwi = nib.load(snakemake.input.dwi)
dwi_data = dwi.get_fdata()
config = snakemake.input.uGUIDE_config
model = config['microstructure_model_name']

idx = np.nonzero(mask)

f = open(snakemake.log.log, "a")
f.write(f'Estimation of the microstructure parameters from the test signals')
f.close()

nb_voxels = idx_mask[0].shape[0]

start_time = time.time()

if f"postprocess_{model}" in dir(du):
    postprocessing = postprocess_{model}
else:
    postprocessing = None

estimates = Parallel(n_jobs=-1)(delayed(estimate_microstructure)(dwi_data[idx_mask[0][i],idx_mask[1][i],idx_mask[2][i],:],
                                                                 config,
                                                                 postprocessing=postprocessing,
                                                                 voxel_id=i,
                                                                 plot=False)
                                                                 for i in np.arange(nb_voxels))

stop_time = time.time()

f = open(snakemake.log.log, "a")
f.write(f'Time to estimate parameters in all voxels:', stop_time - start_time)
f.close()

final = np.zeros((mask.shape[0], mask.shape[1], mask.shape[2], len(config['prior_postprocessing']), 5))

for idx in np.arange(nb_voxels):

    i = idx_mask[0][idx]
    j = idx_mask[1][idx]
    k = idx_mask[2][idx]

    final[i,j,k,:,:] = estimates[idx]

for p, folderpath in enumerate(snakemake.output.maps):

    param_map_nii = nib.Nifti1Image(final[...,p,:].astype('<f4'), affine=dwi.affine)
    param_map_nii.to_filename(folderpath)

f = open(snakemake.output.image_map, "a")
f.write("Index 0: Maximum a posteriori, Index 1: Mask, Index 2: Degeneracy, Index 3: Uncertainty, Index 4: Ambiguity")
f.close()

tmpdir = snakemake.params.tmpdir
subprocess.run(['rm','-r', tmpdir])