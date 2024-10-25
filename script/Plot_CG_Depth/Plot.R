#!/bin/Rscript


#package 
package_name <- "htmlwidgets"
if (!require(package_name, character.only = TRUE)) {
  install.packages(package_name)
  library(package_name, character.only = TRUE)
} else {
  library(package_name, character.only = TRUE)
}

package_name <- "dplyr"
if (!require(package_name, character.only = TRUE)) {
  install.packages(package_name)
  library(package_name, character.only = TRUE)
} else {
  library(package_name, character.only = TRUE)
}

package_name <- "ggplot2"
if (!require(package_name, character.only = TRUE)) {
  install.packages(package_name)
  library(package_name, character.only = TRUE)
} else {
  library(package_name, character.only = TRUE)
}

package_name <- "egg"
if (!require(package_name, character.only = TRUE)) {
  install.packages(package_name)
  library(package_name, character.only = TRUE)
} else {
  library(package_name, character.only = TRUE)
}

package_name <- "argparse"
if (!require(package_name, character.only = TRUE)) {
  install.packages(package_name)
  library(package_name, character.only = TRUE)
} else {
  library(package_name, character.only = TRUE)
}

package_name <- "plotly"
if (!require(package_name, character.only = TRUE)) {
  install.packages(package_name)
  library(package_name, character.only = TRUE)
} else {
  library(package_name, character.only = TRUE)
}




#script
parser <- ArgumentParser(description= 'recup membres clusters of interest')

parser$add_argument('--input_taxResult', '-it', help= 'tab_taxResult_tax_per_contig (metaeuk)')
parser$add_argument('--input_cov', '-ic', help= 'stat dataframe')
parser$add_argument('--input_CG', '-icg', help= '%CG')
parser$add_argument('--input_Busco', '-ib', help= 'Busco result')
parser$add_argument('--input_depth', '-id', help= 'depth median per contigs')


parser$add_argument('--output_Plot', '-o', help= 'CG depth plot')
parser$add_argument('--output_Plot_inter', '-oi', help= 'same plot but interactive')

xargs<- parser$parse_args()

#tableau a charger 
tab_taxResult_tax_per_contig <- read.delim(xargs$input_taxResult, header=FALSE, sep="\t", stringsAsFactors=FALSE)
tab_coverage <- read.delim(xargs$input_cov, header=FALSE, comment.char="#")
tab_CG <-  read.delim(xargs$input_CG)
tab_Busco <-read.delim(xargs$input_Busco, header=FALSE, comment.char="#")
tab_depth_median <- read.delim(xargs$input_depth, header=FALSE)



#modif tableau par contig 
tax_split <- strsplit(tab_taxResult_tax_per_contig$V9, ";")
tax_df <- do.call(rbind, lapply(tax_split, function(x) c(x, rep(NA, max(lengths(tax_split)) - length(x)))))
tab_taxResult_tax_per_contig <- cbind(tab_taxResult_tax_per_contig, tax_df)
tab_taxResult_tax_per_contig$name <- gsub("_", "|", tab_taxResult_tax_per_contig$V1)
tab_taxResult_tax_per_contig$name <- sub(".*scaffold", "scaffold", tab_taxResult_tax_per_contig$name )
colnames(tab_taxResult_tax_per_contig)[colnames(tab_taxResult_tax_per_contig) == "V1"] <- "Scaffold"
  
# tableau information sur le coverage 
colnames(tab_coverage) <- c("name", "startpos", "endpos", "numreads", "covbases", "coverage", "meandepth", "meanbaseq", "meanmapq")

# tableau Busco 
colnames(tab_Busco) <- c("ID", "statut", "name", "start", "end", "strand", "col7", "col8", "link", "fonction")
tab_Busco$Busco <- "oui"

colnames(tab_depth_median) <- c("name", "depth_median")


# fusion des tableaux 
tab_taxo_coverage <- merge(tab_coverage, tab_taxResult_tax_per_contig, by = "name", all.x = TRUE)  
tab_taxo_coverage_CG <- merge(tab_CG,tab_taxo_coverage, by = "Scaffold", all.x = TRUE)  
tab_taxo_coverage_CG_median <- merge(tab_taxo_coverage_CG,tab_depth_median,by ="name", all.x = TRUE)
tab_full <- merge(tab_taxo_coverage_CG_median,tab_Busco,by ="name", all.x = TRUE)


# rajouter une colonne domaine 
tab_full <- tab_full %>%
  mutate(domaine = case_when(
    grepl("^d_", `1`) ~ `1`,
    grepl("^d_", `2`) ~ `2`,
    TRUE ~ NA_character_
  ))


# Supprimer le préfixe 'd_' de la colonne 'domaine'
tab_full <- tab_full %>%
  mutate(domaine = gsub("^d_", "", domaine))

# remplacer les NA par non 
tab_full$Busco[is.na(tab_full$Busco)] <- "non"





# Plot
theme_set(theme_bw())  # pre-set the bw theme.

# title
title <- bquote(paste("Plot GC depth"))

# Scatter plot
scatterPlot <- ggplot(tab_full, aes(x = GC_Content..., y = log(depth_median), colour = domaine)) +
  geom_point() + 
  xlab("GC") + 
  ylab("Log Coverage depth") +
  scale_shape_manual(values = c(3, 15))+  
  theme(legend.position = "none")


# Right boxplot
right_plot <- ggplot(tab_full, aes(x = domaine, y = log(depth_median), colour = domaine)) + 
  geom_boxplot(varwidth = F) +
  theme(axis.text.x = element_blank(), 
        axis.title = element_blank(), 
        legend.position = "none", 
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +  
  theme(legend.position = "right")

# Upper boxplot
upper_plot <- ggplot(tab_full, aes(x = domaine, y = GC_Content..., colour = domaine)) + 
  geom_boxplot(varwidth = F) +
  theme(axis.text.y = element_blank(), 
        axis.title = element_blank(), 
        legend.position = "none", 
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  coord_flip() +
  ggtitle(title)

# Blank plot
blankPlot <- ggplot() +
  geom_blank(aes(1, 1)) +
  theme(
    plot.background = element_blank(), 
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(), 
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_blank(), 
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.line = element_blank()
  )

# Combine plots
Lb <- ggarrange(upper_plot, blankPlot, scatterPlot, right_plot, ncol = 2, widths = c(5, 1), heights = c(1, 5))

# Enregistrement du graphique 
ggsave(filename = xarg$output_Plot, plot = Lb, width = 10, height = 6)





#plot interactif


# Définir une palette de couleurs pour les domaines
colors <- c(
  "Bacteria" = "blue3",    # Couleur pour Bacteria
  "Eukaryota" = "chartreuse3",   # Couleur pour Eukaryota
  "Viruses" = "salmon2",      # Couleur pour Viruses
  "NA" = "grey"            # Couleur pour NA
)

# Définir des formes pour 'oui' et 'non'
shapes <- c("oui" = 5, "non" = 1)

# Créer une nouvelle colonne qui combine 'domaine' et 'Busco'
tab_full$domaine_busco <- interaction(tab_full$domaine, tab_full$Busco)

# Créer un ggplot
scatterPlot <- ggplot(tab_full, aes(x = GC_Content..., y = log(depth_median), colour = domaine, shape = Busco)) +
  geom_point(size = 3, alpha = 0.7) +  # Définir une opacité fixe pour tous les points
  scale_colour_manual(values = colors) +  
  scale_shape_manual(values = shapes) +  
  labs(colour = "Domaine", shape = "Busco") +  
  theme(legend.position = "right")


# Convertir en plot interactif
interactive_plot <- ggplotly(scatterPlot)

# Afficher le plot interactif
interactive_plot


#enregister
saveWidget(interactive_plot, xarg$output_Plot_inter, selfcontained = TRUE)


