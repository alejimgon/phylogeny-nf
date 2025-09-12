# Phylogenetic Pipeline (phylogeny-nf)

This repository provides a reproducible pipeline for phylogenetic analysis using Nextflow, MAFFT, trimAl, and IQ-TREE. The workflow supports automated alignment, trimming, and tree inference for protein or nucleotide sequences.

## Features
- Automated environment setup with Conda
- Multiple sequence alignment using MAFFT
- Alignment trimming with trimAl
- Phylogenetic tree inference using IQ-TREE
- Organized output directories for results

## Requirements
- Miniconda/Anaconda
- Nextflow (installed via Conda environment)

## Installation
Clone the repository:

```bash
git clone https://github.com/alejimgon/phylogeny-nf.git
cd phylogeny-nf
```

Set up the Conda environment:

```bash
source env/setup.sh
```

This will create and activate the `phylogeny-nf` environment with all dependencies.

## Usage
Prepare your input files:

- Place your FASTA files in `fasta_inputs/`

Run the pipeline:

```bash
nextflow run main.nf
```

## Output
Results are saved in the `results/` directory:
- `results/mafft/` for alignments
- `results/trimal/` for trimmed alignments
- `results/iqtree/` for phylogenetic trees

## Troubleshooting
**Conda environment not activated:**
Always use `source env/setup.sh` to ensure the environment is activated in your current shell.

**Missing dependencies:**
Re-run the setup script or check `env/env.yaml`.

## License
This project is for non-commercial use.
See LICENSE for details.

## Citation
If you use this pipeline, please cite MAFFT, trimAl, IQ-TREE, and Nextflow.

## Developed by
Alejandro Jiménez-González
