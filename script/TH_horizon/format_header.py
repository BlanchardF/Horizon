#!/usr/bin/env python3
import os
import sys

# Récupérer les arguments depuis la ligne de commande
input_file_path = sys.argv[1]
order_file_path = sys.argv[2]
output_file_path = sys.argv[3]

# Extraire le nom de l'espèce depuis le chemin du fichier d'entrée
species_name = os.path.basename(os.path.dirname(input_file_path))

# Ouvrir les fichiers
with open(input_file_path, 'r') as preds_file, open(order_file_path, 'r') as order_file:
    # Lire le contenu des fichiers
    preds_lines = preds_file.readlines()
    order_lines = order_file.readlines()

# Créer un dictionnaire pour stocker les ordres par espèce
order_dict = {}
for line in order_lines:
    parts = line.strip().split()
    if len(parts) == 2:
        species_id = parts[0]
        order_name = parts[1]
        order_dict[species_id] = order_name

# Créer une liste pour stocker les nouvelles lignes du fichier predsResults
new_preds_lines = []

# Parcourir le fichier predsResults et modifier les en-têtes
for line in preds_lines:
    if line.startswith('>'):  # Si c'est un en-tête
        header_parts = line.strip().split('|')
        header_id = header_parts[0][1:]  # Obtenir l'ID de l'en-tête (en enlevant '>')

        scaffold_info = header_parts[1]
        scaffold_size = scaffold_info.split('_')[3]
        strand = header_parts[2]
        
        start = header_parts[6]
        end = header_parts[7]

        order_name = order_dict.get(species_name, 'order')

        # Créer le nouvel en-tête
        new_header = f">{header_id}_species_{scaffold_info}_order{order_name}_start{start}_end{end}_strand{strand}\n"
        new_preds_lines.append(new_header)
    else:
        new_preds_lines.append(line)

# Écrire le nouveau contenu dans le fichier de sortie
with open(output_file_path, 'w') as output_file:
    output_file.writelines(new_preds_lines)

print(f"Les en-têtes pour l'espèce {species_name} ont été reformattés dans {output_file_path}.")
