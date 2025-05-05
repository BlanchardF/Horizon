#!/usr/bin/env python3

import pandas as pd
import argparse
import os

def add_go_column(input_tsv1, input_tsv2, output_tsv):
    # Vérifiez l'existence des fichiers d'entrée
    if not os.path.exists(input_tsv1) or not os.path.exists(input_tsv2):
        raise FileNotFoundError("Un ou plusieurs fichiers d'entrée sont introuvables.")
    
    # Charger les tableaux
    table1 = pd.read_csv(input_tsv1, sep='\t')
    table2 = pd.read_csv(
        input_tsv2, 
        sep='\t', 
        header=None, 
        usecols=[0, 6], 
        names=["Prot", "GO"], 
        dtype=str
    )
    
    # Ajouter la colonne GO au premier tableau en utilisant une jointure
    merged_table = table1.merge(table2, left_on="Prot", right_on="Prot", how="left")
    
    # Sauvegarder le tableau fusionné
    merged_table.to_csv(output_tsv, sep='\t', index=False)
    print(f"Tableau fusionné sauvegardé avec succès dans {output_tsv}.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ajoute une colonne 'GO' au premier tableau à partir du deuxième tableau basé sur des correspondances.")
    parser.add_argument("input_tsv1", help="Chemin du premier fichier TSV (tableau des cds *_Tab_cds.tsv)")
    parser.add_argument("input_tsv2", help="Chemin du deuxième fichier TSV (tableau des correspondance avec les GO : idmapping_selected.tab trouvable sur uniprot)")
    parser.add_argument("output_tsv", help="Chemin du fichier TSV de sortie")
    
    args = parser.parse_args()
    
    # Appeler la fonction principale
    add_go_column(args.input_tsv1, args.input_tsv2, args.output_tsv)
