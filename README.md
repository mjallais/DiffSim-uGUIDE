# DiffSim-μGUIDE

This project is part of the [VIC-HACK 2024](https://github.com/Lewis-Kitchingman/VIC-HACK-2024.git) hackathon organised at Cardiff University and is co-lead by Bradley Karat and Maëliss Jallais.

The aim of this project is to integrate simulations from [DiffSimGEN](https://github.com/Bradley-Karat/DiffSimGen.git) into [μGUIDE](https://github.com/mjallais/uGUIDE.git).

If you are using this repository, please cite μGUIDE (see preprint [here](https://arxiv.org/abs/2312.17293)):
```bibtex
@misc{jallais2023muguide,
      title={$\mu$GUIDE: a framework for microstructure imaging via generalized uncertainty-driven inference using deep learning}, 
      author={Maëliss Jallais and Marco Palombo},
      year={2023},
      eprint={2312.17293},
      archivePrefix={arXiv},
      primaryClass={eess.IV}
}
```

## Installation
Clone the repository with
```
git clone https://github.com/mjallais/DiffSim-uGUIDE.git
```
Create a virtual environment with
```
python -m venv venv_uGUIDE
```
Activate it with
```
source venv_uGUIDE/bin/activate
```
then install the required dependencies with
```
cd DiffSim-uGUIDE
pip install .
```

## Usage
If installed with pip, the package can be ran with:
```
diffsimuguide
```
Run this with the -h flag to get a detailed summary of the toolbox and its flags plus required arguments.
## Example Toolbox Call
For a dry-run:
```
diffsimuguide /path/to/bids/inputs /path/for/outputs participant --model NODDI_watson --SNR 25,50 -np
```
To actually run the software:
```
diffsimuguide /path/to/bids/inputs /path/for/outputs participant --model NODDI_watson --SNR 25,50 --cores all
```
## Example File Struture
```
└── bids
    ├── sub-01
    │ └── dwi
    │     ├── sub-01_brain_mask.nii.gz
    │     ├── sub-01_dwi.bval
    │     ├── sub-01_dwi.bvec
    │     ├── sub-01_dwi.nii.gz
    ├── sub-02
    │ └── dwi
    │     ├── sub-02_brain_mask.nii.gz
    │     ├── sub-02_dwi.bval
    │     ├── sub-02_dwi.bvec
    │     ├── sub-02_dwi.nii.gz
```
Alternatively, the `--path-dwi` flag can be used to override BIDS by specifying absolute paths. For example: `--path-dwi /path/to/my_data/{subject}/dwi.nii.gz`. The other necessary files (.bval, .bvec, and brainmask) must be labelled in a similar fashion (i.e. all have the same prefix).
