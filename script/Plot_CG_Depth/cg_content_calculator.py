#!/usr/bin/env python3

import argparse
from Bio import SeqIO

# Fonction pour calculer le taux de CG
def calculate_gc_content(sequence):
    gc_count = sequence.count("C") + sequence.count("G")
    return (gc_count / len(sequence)) * 100 if len(sequence) > 0 else 0

# Fonction principale
def main(input_fasta, output_file):
    # Liste pour stocker les résultats
    gc_results = []

    # Lecture du fichier FASTA
    for record in SeqIO.parse(input_fasta, "fasta"):
        scaffold_name = record.id
        sequence = str(record.seq).upper()
        gc_content = calculate_gc_content(sequence)
        gc_results.append([scaffold_name, gc_content])

    # Écriture des résultats dans un fichier TSV
    with open(output_file, "w") as out_file:
        out_file.write("Scaffold\tGC_Content(%)\n")
        for scaffold, gc_content in gc_results:
            out_file.write(f"{scaffold}\t{gc_content:.2f}\n")

    print(f"Tableau des taux de GC généré avec succès : {output_file}")

# Définition des arguments de ligne de commande
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Calcul du taux de GC pour chaque scaffold dans un fichier FASTA.")
    parser.add_argument("input_fasta", help="Chemin du fichier FASTA en entrée.")
    parser.add_argument("output_file", help="Chemin du fichier de sortie (TSV).")
    args = parser.parse_args()

    # Appel de la fonction principale avec les arguments fournis
    main(args.input_fasta, args.output_file)
