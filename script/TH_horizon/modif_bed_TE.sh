#!/bin/bash

# Chemin vers le répertoire contenant les fichiers .bed
directory="/beegfs/data/fblanchard/horizon/TH_horizon/TE"

# Parcours de chaque fichier .bed dans le répertoire
for file in "$directory"/*.bed; do
    # Extraction du nom de l'espèce à partir du nom de fichier
    species=$(basename "$file" | cut -d'_' -f1,2)

    # Création d'un fichier temporaire pour stocker les résultats modifiés
    tmp_file=$(mktemp)

    # Modification du fichier : ajout du nom de l'espèce suivi d'un underscore et remplacement des '|' par '_'
    awk -v species="$species" '{gsub(/\|/, "_"); print species "_" $0}' "$file" > "$tmp_file"

    # Remplacement du fichier original par le fichier modifié
    mv "$tmp_file" "$file"
done
