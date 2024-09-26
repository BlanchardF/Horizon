#!/usr/bin/env python3
import os

# Définir le chemin du fichier d'entrée
input_file_path = '/beegfs/data/fblanchard/horizon/Metaeuk/epiperola_vaferella/epiperola_vaferella_predsResults.codon.fas'
species_name = os.path.basename(os.path.dirname(input_file_path))  # Extraire le nom de l'espèce du chemin

# Ouvrir les fichiers
with open(input_file_path, 'r') as preds_file, \
     open('/beegfs/data/aportal/horizon/TH_horizon_triplets/lists/species_horizon_order.txt', 'r') as order_file:
    
    # Lire le contenu des fichiers
    preds_lines = preds_file.readlines()
    order_lines = order_file.readlines()

# Créer un dictionnaire pour stocker les ordres par espèce
order_dict = {}
for line in order_lines:
    parts = line.strip().split()
    if len(parts) == 2:
        species_id = parts[0]  # Espèce
        order_name = parts[1]  # Ordre
        order_dict[species_id] = order_name  # Stocker l'espèce et son ordre

# Créer une liste pour stocker les nouvelles lignes du fichier predsResults
new_preds_lines = []

# Parcourir le fichier predsResults et modifier les en-têtes
for line in preds_lines:
    if line.startswith('>'):  # Si c'est un en-tête
        header_parts = line.strip().split('|')
        header_id = header_parts[0][1:]  # Obtenir l'ID de l'en-tête (en enlevant '>')

        # Conserver l'en-tête original
        scaffold_info = header_parts[1]
        scaffold_size = scaffold_info.split('_')[3]
        strand = header_parts[2]
        
        # Extraire la position de départ et de fin depuis les informations de l'en-tête
        start = header_parts[6]  
        end = header_parts[7]    

        # Récupérer l'ordre à partir du dictionnaire en utilisant le nom de l'espèce
        order_name = order_dict.get(species_name, 'order')  # Par défaut, 'order' si pas trouvé

        # Créer le nouvel en-tête
        new_header = f">{header_id}_species_{scaffold_info}_{strand}_order{order_name}_start{start}_end{end}\n"
        new_preds_lines.append(new_header)
    else:
        new_preds_lines.append(line)  # Ajouter les séquences sans modification

# Écrire le nouveau contenu dans un fichier de sortie
with open('test.fas', 'w') as output_file:
    output_file.writelines(new_preds_lines)

print("Les en-têtes ont été reformattés selon la nouvelle structure.")
