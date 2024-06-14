import numpy as np
import nibabel as nib


dwi = nib.load(snakemake.input.dwi)
dwidata = dwi.get_fdata()
sx,sy,sz,sb = dwidata.shape
mask = nib.load(snakemake.input.mask)
maskdata = mask.get_fdata()

bvecs = np.loadtxt(snakemake.input.bvec)
bvals = np.loadtxt(snakemake.input.bval)

bvals = np.multiply(np.round(bvals/100),100)

S0mean = np.nanmean(np.double(dwidata[:,:,:,bvals<=100]),axis=3)
S0meanflat = S0mean.flatten()
maskflat = maskdata.flatten()
dwidataflat = np.reshape(dwidata,[sx*sy*sz,sb])
dwidataflatnorm = np.zeros((sx*sy*sz,sb))

for ii in range(len(S0meanflat)):
    if maskflat[ii]==1:
        dwidataflatnorm[ii,:] = dwidataflat[ii,:] / S0meanflat[ii]

dwireshape = np.reshape(dwidataflatnorm,[sx,sy,sz,sb])
img = nib.Nifti1Image(dwireshape,dwi.affine)
nib.save(img,snakemake.output.normalized_data)
