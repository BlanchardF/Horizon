#!/bin/bash

# Dossiers
FASTQ_DIR="data/fastq"
GENOME_DIR="data/genome"
MANIFEST_DIR="manifests"

# Créer le dossier de sortie s'il n'existe pas
mkdir -p "$MANIFEST_DIR"

# Paramètres constants
PLATFORM="ILLUMINA"
INSTRUMENT="Illumina HiSeq 2500"
LIB_SOURCE="GENOMIC"
LIB_SELECTION="RANDOM"
LIB_STRATEGY="WGS"
ASSEMBLY_TOOL="MEGAHIT"
ASSEMBLY_TYPE="clonal"
COVERAGE="100"  # modifier automatiquement avec le script inject.coverage
STUDY="TO_DEFINE"  # à mettre à jour manuellement après création dans ENA

# Lecture ligne par ligne du fichier d'espèces
while IFS=$'\t' read -r species specimen; do
    tag="${species}_${specimen}"

    # Fichiers
    fq1="${FASTQ_DIR}/${tag}_1.fastq.gz"
    fq2="${FASTQ_DIR}/${tag}_2.fastq.gz"
    fa="${GENOME_DIR}/${tag}.fa"

    # Check existence
    if [[ ! -f "$fq1" || ! -f "$fq2" || ! -f "$fa" ]]; then
        echo "⛔ Fichiers manquants pour $tag"
        continue
    fi

    #### MANIFEST READS ####
    cat > "${MANIFEST_DIR}/${tag}_reads.manifest" <<EOF
STUDY=${STUDY}
SAMPLE=${tag}
NAME=${tag}_reads
PLATFORM=${PLATFORM}
INSTRUMENT_MODEL=${INSTRUMENT}
LIBRARY_SOURCE=${LIB_SOURCE}
LIBRARY_SELECTION=${LIB_SELECTION}
LIBRARY_STRATEGY=${LIB_STRATEGY}
FASTQ=${fq1}
FASTQ2=${fq2}
EOF

    #### MANIFEST GENOME ####
    cat > "${MANIFEST_DIR}/${tag}_genome.manifest" <<EOF
STUDY=${STUDY}
SAMPLE=${tag}
NAME=${tag}_genome
ASSEMBLYNAME=${tag}_assembly
ASSEMBLY_TYPE=${ASSEMBLY_TYPE}
COVERAGE=${COVERAGE}
PROGRAM=${ASSEMBLY_TOOL}
PLATFORM=${PLATFORM}
FASTA=${fa}
EOF

    echo "✅ Manifest créés pour $tag"

done < Species_specimen_Tachinidae.txt
