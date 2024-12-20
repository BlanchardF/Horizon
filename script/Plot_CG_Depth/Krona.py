#!/usr/bin/env python3

import pandas as pd
import sys
import subprocess

# Vérification des arguments
if len(sys.argv) != 4:
    print("Usage: python script.py <input_file.tsv> <output_file.html> <temp_unique_lines_output.tsv>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]
temp_unique_lines = sys.argv[3]

# Vérification de l'existence du fichier d'entrée
try:
    # Charger les données en utilisant pandas
    data = pd.read_csv(input_file, sep='\t')
except FileNotFoundError:
    print(f"Erreur : Le fichier d'entrée '{input_file}' n'existe pas.")
    sys.exit(1)

# Vérification des colonnes nécessaires
required_columns = [28, 29, 30, 31, 32, 33, 34, 35, 4]  # index des colonnes (0-indexé)
for col in required_columns:
    if col >= len(data.columns):
        print(f"Erreur : La colonne {col + 1} est absente du fichier d'entrée.")
        sys.exit(1)

# Extraire les colonnes nécessaires (ajuster les indices car pandas est 0-indexé)
data_subset = data.iloc[:, [28, 29, 30, 31, 32, 33, 34, 35, 4]]

# Remplacer les valeurs NA par "NA" pour ne pas les exclure lors du regroupement
data_subset = data_subset.fillna("NA")

# Grouper par les colonnes 29 à 36 (indexés comme col1 à col8 ici) et sommer col5 (col9 ici)
grouped = data_subset.groupby([
    data_subset.columns[0], data_subset.columns[1], data_subset.columns[2], 
    data_subset.columns[3], data_subset.columns[4], data_subset.columns[5], 
    data_subset.columns[6], data_subset.columns[7]
])[data_subset.columns[8]].sum().reset_index()

# Renommer la colonne contenant la somme pour clarté
grouped.rename(columns={data_subset.columns[8]: "sum_col5"}, inplace=True)

# Réorganiser les colonnes pour que 'sum_col5' soit en première position
columns = ["sum_col5"] + [col for col in grouped.columns if col != "sum_col5"]
grouped = grouped[columns] 

# Sauvegarder les lignes uniques dans un fichier temporaire sans en-tête
grouped.iloc[:, 1:].to_csv(temp_unique_lines, sep='\t', index=False, header=False)

# Sauvegarder les résultats finaux dans un fichier temporaire pour ktImportText sans en-tête
temp_output = temp_unique_lines.replace('.tsv', '_with_sum.tsv')
grouped.to_csv(temp_output, sep='\t', index=False, header=False)

# Générer un fichier HTML avec ktImportText
try:
    subprocess.run(["ktImportText", "-o", output_file, temp_output], check=True)
except FileNotFoundError:
    print("Erreur : L'outil ktImportText n'est pas installé ou introuvable dans le PATH.")
    sys.exit(1)

print(f"Traitement terminé. Résultats enregistrés dans {output_file}.")



############################
#### Krona for all data ####
############################

# find /beegfs/data/fblanchard/horizon/Plot_CG_Depth/*/* -wholename '*_Taxo_resume_with_sum.tsv' | xargs ktImportText -o /beegfs/data/fblanchard/horizon/Plot_CG_Depth/summary/Krona_summary.html
