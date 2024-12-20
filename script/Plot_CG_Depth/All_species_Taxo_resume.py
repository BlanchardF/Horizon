import os
import glob

# Dossier contenant les fichiers d'entrée
input_files = glob.glob("/beegfs/data/fblanchard/horizon/Plot_CG_Depth/*/*_Taxo_resume_with_sum.tsv")

# Fichier de sortie
output_file = "/beegfs/data/fblanchard/horizon/Plot_CG_Depth/summary/All_species_Taxo_resume.tsv"

# Traitement des fichiers
with open(output_file, "w") as outfile:
    header_written = False  # Pour éviter d'écrire plusieurs fois le header
    for file in input_files:
        # Extraire les deux premières parties du nom du fichier
        file_basename = os.path.basename(file)
        identifier = "_".join(file_basename.split("_")[:2])

        with open(file, "r") as infile:
            for i, line in enumerate(infile):
                # Si c'est le header et qu'il a déjà été écrit, on l'ignore
                if i == 0 and header_written:
                    continue
                # Ajouter l'identifiant au début de chaque ligne
                outfile.write(f"{identifier}\t{line}")
        header_written = True
