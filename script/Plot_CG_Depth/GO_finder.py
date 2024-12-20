#!/usr/bin/env python3

import pandas as pd
import argparse

def add_go_column(input_tsv1, input_tsv2, output_tsv):
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

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ajoute une colonne 'GO' au premier tableau à partir du deuxième tableau basé sur des correspondances.")
    parser.add_argument("input_tsv1", help="Chemin du premier fichier TSV (tableau des cds *_Tab_cds.tsv)")
    parser.add_argument("input_tsv2", help="Chemin du deuxième fichier TSV (tableau des correspondance avec les GO : idmapping_selected.tab trouvable sur uniprot)")
    parser.add_argument("output_tsv", help="Chemin du fichier TSV de sortie")
    
    args = parser.parse_args()
    
    add_go_column(args.input_tsv1, args.input_tsv2, args.output_tsv)


#./GO_finder.py /beegfs/data/fblanchard/horizon/Plot_CG_Depth/xiphosomella_wirra/xiphosomella_wirra_Tab_cds.tsv /beegfs/data/fblanchard/horizon/db/idmapping_selected.tab test.tsv