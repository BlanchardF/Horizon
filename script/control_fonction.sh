#!/bin/bash

# Fichier contenant les identifiants UniRef
input_file="/beegfs/data/fblanchard/horizon/Metaeuk/epiperola_vaferella/epiperola_vaferella_pred_UniRef_id.txt"
output_file="/beegfs/data/fblanchard/horizon/Metaeuk/epiperola_vaferella/uniref_protein_info.txt"

# Vide le fichier de sortie si déjà existant
> "$output_file"

# Boucle pour chaque identifiant dans le fichier
while IFS= read -r uniref_id; do
    echo "Fetching information for $uniref_id..." >> "$output_file"
    # Utiliser l'API UniProt pour récupérer les informations sur la protéine
    curl -s "https://rest.uniprot.org/uniprotkb/search?query=$uniref_id&format=json" | jq '.results[] | {protein_name: .proteinDescription.recommendedName.fullName.value, organism: .organism.scientificName, accession: .primaryAccession}' >> "$output_file"
    echo "" >> "$output_file"
done < "$input_file"
