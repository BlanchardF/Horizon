#!/bin/bash 
#SBATCH --partition=normal 
#SBATCH --time=2:00:00 
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G 
#SBATCH --output=/beegfs/data/fblanchard/horizon/Plot_CG_Depth/grilles/std_output.txt 
#SBATCH --error=/beegfs/data/fblanchard/horizon/Plot_CG_Depth/grilles/std_error.txt 


# Définir les chemins
base_dir="/beegfs/data/fblanchard/horizon/Plot_CG_Depth/*/"
output_dir="/beegfs/data/fblanchard/horizon/Plot_CG_Depth/grilles"
mkdir -p "$output_dir"  # Créer le répertoire de sortie

# Rechercher toutes les images dans les sous-dossiers
images=($(find $base_dir -type f \( -iname "*.jpg" -o -iname "*.png" \)))

# Vérifier s'il y a des images
if [ ${#images[@]} -eq 0 ]; then
    echo "Aucune image trouvée dans $base_dir"
    exit 1
fi

# Diviser les images en lots de 25
batch_size=25
total_images=${#images[@]}
batch_count=$((total_images / batch_size))

if [ $((total_images % batch_size)) -gt 0 ]; then
    batch_count=$((batch_count + 1))  # Ajouter un lot supplémentaire pour les images restantes
fi

# Traitement des lots d'images
counter=0
for ((batch=0; batch<batch_count; batch++)); do
    # Créer un sous-lot d'images pour chaque groupe de 25 images
    start=$((batch * batch_size))
    end=$((start + batch_size - 1))
    if [ $end -ge $total_images ]; then
        end=$((total_images - 1))
    fi
    current_images=("${images[@]:$start:$((end - start + 1))}")
    
    # Créer un répertoire temporaire pour les fichiers partiels
    temp_dir=$(mktemp -d)
    partial_files=()
    
    # Redimensionner et traiter les images par lot
    resized_images=()
    for img in "${current_images[@]}"; do
        resized_image=$(mktemp)
        convert "$img" -resize 3200x\> "$resized_image"
        resized_images+=("$resized_image")
    done

    # Créer le fichier partiel pour ce lot d'images
    partial_file="$output_dir/grille_batch_$batch.jpg"
    montage "${resized_images[@]}" -tile 5x5 -geometry +2+2 -font "DejaVu-Sans" "$partial_file"
    
    # Vérifier si le lot a été traité avec succès
    if [ $? -eq 0 ]; then
        echo "Grille pour le lot $batch créée avec succès : $partial_file"
    else
        echo "Erreur lors de la création de la grille pour le lot $batch."
        rm -f "$partial_file"
    fi

    # Nettoyage des fichiers temporaires
    rm -rf "$temp_dir"
done

echo "Traitement terminé."
