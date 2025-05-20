#!/bin/bash

COVERAGE_FILE="../coverage_by_sample.tsv"

# Lecture ligne par ligne de chaque fichier .manifest
for manifest in *.manifest; do
    # Récupère l'ID de l'échantillon depuis la ligne SAMPLE=
    sample_id=$(grep "^SAMPLE=" "$manifest" | cut -d "=" -f 2)

    # Récupère la couverture depuis le fichier TSV (ignore l'en-tête)
    coverage=$(awk -v id="$sample_id" 'BEGIN{FS="\t"} $1 == id {print $4}' "$COVERAGE_FILE")

    if [[ -z "$coverage" ]]; then
        echo "⛔ Aucune valeur de couverture trouvée pour $sample_id"
        continue
    fi

    # Si la ligne COVERAGE existe déjà, on la remplace. Sinon, on l'ajoute.
    if grep -q "^COVERAGE=" "$manifest"; then
        sed -i "s/^COVERAGE=.*/COVERAGE=${coverage}/" "$manifest"
        echo "🔄 Mise à jour COVERAGE=$coverage dans $manifest"
    else
        echo "COVERAGE=$coverage" >> "$manifest"
        echo "➕ Ajout COVERAGE=$coverage à $manifest"
    fi
done
