#!/bin/bash

# Dossiers contenant les fichiers
FASTQ_DIR="data/fastq"
GENOME_DIR="data/genome"
OUTPUT="coverage_by_sample.tsv"

# En-tête du fichier de sortie
echo -e "sample_id\tgenome_size\tbases_in_reads\tcoverage" > "$OUTPUT"

# Parcours des fichiers FASTA (assemblages)
for genome_file in ${GENOME_DIR}/*.fa; do
    # Extraction de l'identifiant (sans chemin ni extension)
    base=$(basename "$genome_file" .fa)

    # Correspondants fastq.gz
    fq1="${FASTQ_DIR}/${base}_1.fastq.gz"
    fq2="${FASTQ_DIR}/${base}_2.fastq.gz"

    # Vérifie l'existence des reads
    if [[ ! -f "$fq1" || ! -f "$fq2" ]]; then
        echo "⛔ FASTQ manquant pour $base" >&2
        continue
    fi

    # Taille du génome (en bases, sans entêtes et sans retours à la ligne)
    genome_size=$(grep -v "^>" "$genome_file" | wc | awk '{print $3 - $1}')

    # Taille des reads (somme des longueurs ligne 2 de chaque groupe de 4)
    fq1_bases=$(zcat "$fq1" | awk 'NR%4==2 {s+=length($0)} END {print s}')
    fq2_bases=$(zcat "$fq2" | awk 'NR%4==2 {s+=length($0)} END {print s}')
    total_bases=$((fq1_bases + fq2_bases))

    # Couverture = total_reads / genome_size (valeur entière)
    if [[ "$genome_size" -gt 0 ]]; then
        coverage=$(echo "$total_bases / $genome_size" | bc)
    else
        coverage="NA"
    fi

    # Écriture dans le fichier
    echo -e "${base}\t${genome_size}\t${total_bases}\t${coverage}" >> "$OUTPUT"
    echo "✅ $base : coverage = ${coverage}x"

done
