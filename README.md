# Phylogenetic Pipeline (phylogeny-nf)

This repository provides a reproducible pipeline for phylogenetic analysis using Nextflow, BLASTP, CD-HIT, MAFFT, trimAl, and IQ-TREE. The workflow supports automated BLAST search, clustering, alignment, trimming, and tree inference for protein. The pipeline is highly configurable, allowing users to control each step with parameters.

## Features
- Automated environment setup with Conda
- BLASTP search against a user-specified protein database
- Limit the number of BLAST hits retrieved (parameterized)
- Sequence clustering with CD-HIT (optional)
- Combine original and clustered sequences (optional)
- Multiple sequence alignment using MAFFT
- Alignment trimming with trimAl
- Phylogenetic tree inference using IQ-TREE (optional)
- Highly configurable workflow via Nextflow parameters
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

- Place your FASTA files in `inputs/`

Run the pipeline with default settings:

```bash
nextflow run main.nf --blast_db /path/to/your/blastdb
```

### Optional parameters

- `--blast_num_seq 500` : Number of BLAST hits to retrieve per query (default: 500)
- `--cd_hit true` : Enable CD-HIT clustering (default: false)
- `--cd_hit_ident 0.9` : CD-HIT identity threshold (default: 0.9)
- `--combine true` : Combine original and clustered sequences before alignment (default: false)
- `--phylogeny true` : Run alignment, trimming, and tree inference (default: false)

Example with clustering and phylogeny:

```bash
nextflow run main.nf --blast_db /path/to/your/blastdb --cd_hit true --cd_hit_ident 0.95 --combine true --phylogeny true
```

## Output
Results are saved in the `results/` directory:
- `results/blast/` for BLAST outputs and extracted FASTA
- `results/cdhit/` for clustered and/or combined FASTA files
- `results/mafft/` for alignments
- `results/trimal/` for trimmed alignments
- `results/iqtree/` for phylogenetic trees

## Troubleshooting
**Conda environment not activated:**
Always use `source env/setup.sh` to ensure the environment is activated in your current shell.

**Missing dependencies:**
Re-run the setup script or check `env/env.yaml`.

**No results produced:**
Check that your input files are in the correct `inputs/` directory and that the BLAST database path is correct.

## License
This project is for non-commercial use.
See LICENSE for details.

## Citation
If you use this pipeline, please cite BLAST, CD-HIT, MAFFT, trimAl, IQ-TREE, and Nextflow.

## Developed by
Alejandro Jiménez-González
