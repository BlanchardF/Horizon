#!/usr/bin/env python3

import pandas as pd
import argparse
from ete3 import NCBITaxa

# Initialiser l'objet NCBITaxa pour utiliser les serveurs NCBI directement
ncbi = NCBITaxa()

# Définir les arguments
parser = argparse.ArgumentParser(description="Annotate contigs with full taxonomy based on taxid.")
parser.add_argument('-i', '--input', required=True, help="Chemin du fichier d'entrée contenant les contigs avec taxid.")
parser.add_argument('-o', '--output', required=True, help="Chemin du fichier de sortie avec la taxonomie complète.")
args = parser.parse_args()

# Charger le tableau de contigs en ajoutant les noms de colonnes
column_names = [
    "scaffold", "taxid", "max_rank", "max_rank_value", 
    "cds_count", "cds_assigned", "cds_agree_with_global", 
    "cds_ratio", "taxonomy_details"
]
df = pd.read_csv(args.input, sep='\t', names=column_names)

# Liste des rangs taxonomiques jusqu'à l'espèce
taxonomic_ranks = ["superkingdom", "kingdom", "phylum", "class", "order", "family", "genus", "species"]

# Fonction pour obtenir la taxonomie complète d'un taxid
def get_taxonomy_lineage(taxid):
    try:
        lineage = ncbi.get_lineage(taxid)
        names = ncbi.get_taxid_translator(lineage)
        ranks = ncbi.get_rank(lineage)
        # Créer un dictionnaire avec les rangs et noms taxonomiques
        taxonomy = {rank: names[taxid] for taxid, rank in ranks.items() if rank in taxonomic_ranks}
        # Remplir avec "NA" pour les rangs manquants
        return [taxonomy.get(rank, "NA") for rank in taxonomic_ranks]
    except:
        # En cas d'erreur ou de taxid inexistant
        return ["NA"] * len(taxonomic_ranks)

# Appliquer la fonction pour chaque taxid et ajouter les colonnes de taxonomie au dataframe
df[taxonomic_ranks] = df['taxid'].apply(get_taxonomy_lineage).apply(pd.Series)

# Sauvegarder le tableau final avec la taxonomie complète
df.to_csv(args.output, sep='\t', index=False)


