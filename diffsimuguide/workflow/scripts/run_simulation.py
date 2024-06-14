import numpy as np
from diffsimgen import diffsimrun

SNR = np.array(snakemake.params.SNR[0].split(','),dtype=float)
model = snakemake.params.model
bvals = np.loadtxt(snakemake.input.bval)
bvecs = np.loadtxt(snakemake.input.bvec)
numofsim = snakemake.params.numofsim
paramdist = snakemake.params.paramdist

if paramdist:
    parameter_distribution = np.load(paramdist)
else:
    parameter_distribution = []
   
signal, noiseless_signal, parameters, parameter_names, SNRarr = diffsimrun(model=model,output=snakemake.output.simulated_signals,bval=bvals,bvec=bvecs,SNR=SNR,numofsim=numofsim,parameter_distributions=parameter_distribution)
 