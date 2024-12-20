
#!/bin/Rscript

#########################
### tableau cds clean ###
#########################

library(tidyr)
library(dplyr)
library(argparse)




parser <- ArgumentParser(description= 'recup membres clusters of interest')

parser$add_argument('--input_Temp', '-it', help= 'tableau temporaire avec la taxnomie propre')

parser$add_argument('--output_cds', '-c', help= 'tableau final cds')

xargs<- parser$parse_args()

#tableau a charger 
Tab_cds <- read.delim(xargs$input_Temp, header=T)


# Suppression des colonnes totalement vides
Tab_cds<- Tab_cds[, colSums(!is.na(Tab_cds) & Tab_cds != "") > 0]

head(Tab_cds)

Tab_cds <- Tab_cds %>%
  separate(
    col = scaffold, 
    into = c("col1", "scaffold", "strand", "score_alignement", "Evalue", "nb_exons", "start_position", "end_position", "exon_position"),
    sep = "\\|",
    extra = "merge", # Conserver tout ce qui reste dans une colonne nommée "exon_position"
    fill = "right"   # Remplir avec NA si moins de 8 séparateurs trouvés
  )


Tab_cds <- Tab_cds %>%
  separate(
    col = col1, 
    into = c("Base", "Prot"), 
    sep = "_", 
    extra = "merge", 
    fill = "right"   
  )


# Enregistrer le tableau 
write.table(Tab_cds, xargs$output_cds, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
