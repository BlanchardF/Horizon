#!/bin/bash

# Vérification des arguments
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <input_file.tsv> <output_file.html> <temp_unique_lines_output.tsv>"
    exit 1
fi

input_file="$1"
output_file="$2"
temp_unique_lines="$3"

# Vérification de l'existence du fichier d'entrée
if [[ ! -f "$input_file" ]]; then
    echo "Erreur : Le fichier d'entrée '$input_file' n'existe pas."
    exit 1
fi

# Extraire les lignes uniques et les stocker dans le fichier spécifié par l'utilisateur
awk -F'\t' 'NR>1 {print $29"\t"$30"\t"$31"\t"$32"\t"$33"\t"$34"\t"$35"\t"$36}' "$input_file" | sort | uniq > "$temp_unique_lines"

# Nom du fichier temporaire pour les résultats
temp_output="${temp_unique_lines%.tsv}_with_sum.tsv"

# Initialiser le fichier temporaire
> "$temp_output"

# Calculer la somme des colonnes 5 pour chaque groupe unique
while IFS=$'\t' read -r col29 col30 col31 col32 col33 col34 col35 col36; do
    sum=$(awk -F'\t' -v c29="$col29" -v c30="$col30" -v c31="$col31" -v c32="$col32" -v c33="$col33" -v c34="$col34" -v c35="$col35" -v c36="$col36" '
        $29 == c29 && $30 == c30 && $31 == c31 && $32 == c32 && $33 == c33 && $34 == c34 && $35 == c35 && $36 == c36 {
            sum += $5
        }
        END {
            print sum
        }
    ' "$input_file")
    echo -e "$sum\t$col29\t$col30\t$col31\t$col32\t$col33\t$col34\t$col35\t$col36" >> "$temp_output"
done < "$temp_unique_lines"

# Importer le fichier temporaire avec ktImportText
ktImportText -o "$output_file" "$temp_output"
