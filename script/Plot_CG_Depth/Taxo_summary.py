#!/usr/bin/env python3

import pandas as pd
import glob
import os

# Dossier contenant les fichiers TSV
input_path = "/beegfs/data/fblanchard/horizon/Plot_CG_Depth/*/*_Taxo_resume_with_sum.tsv"
output_file = "/beegfs/data/fblanchard/horizon/Plot_CG_Depth/summary/taxo_summary.tsv"

# Expressions recherchées (modifiable)
expressions = ["Bacteria", "Insecta", "Viruses", "Diptera", "Lepidoptera", "Hymenoptera", "Rickettsiales", "Wolbachia"]

# Initialisation du tableau de résultats
results = []

for file_path in glob.glob(input_path):
    df = pd.read_csv(file_path, sep="\t")
    
    # Calcul de la somme totale (somme de la colonne 'sum_col5')
    total_sum = df['sum_col5'].sum()
    
    # Calcul des sommes pour chaque expression dans la colonne taxonomique (colonne 2 à 8)
    sums = []
    for expr in expressions:
        # Vérifie si l'expression existe dans l'une des colonnes taxonomiques
        match_found = df.iloc[:, 1:8].apply(lambda row: row.str.contains(expr, case=False).any(), axis=1)
        sums.append(df[match_found]['sum_col5'].sum())
    
    # Nettoyage du nom de fichier
    cleaned_filename = os.path.basename(file_path).replace("_Taxo_resume_with_sum.tsv", "")
    
    # Ajout du résultat
    results.append([cleaned_filename] + [total_sum] + sums)

# Création d'un DataFrame final
columns = ["File", "Total_Sum"] + expressions
summary_df = pd.DataFrame(results, columns=columns)

# Sauvegarde dans un fichier TSV
summary_df.to_csv(output_file, sep="\t", index=False)

print(f"Tableau récapitulatif généré : {output_file}")