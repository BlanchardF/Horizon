#!/bin/bash

#SBATCH --partition=normal
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --output=/beegfs/data/fblanchard/horizon/db/std_output.txt
#SBATCH --error=/beegfs/data/fblanchard/horizon/db/std_error.txt


mmseqs createtaxdb UniRef_insecta90_viruses90_bacteria50_clean_DB tmp --ncbi-tax-dump tmp 
