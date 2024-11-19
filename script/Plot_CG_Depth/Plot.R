#!/bin/Rscript

cat("chargement package ")
#package 

package_name <- "svglite"
if (!require(package_name, character.only = TRUE)) {
  install.packages(package_name)
  library(package_name, character.only = TRUE)
} else {
  library(package_name, character.only = TRUE)
}

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

cat("  package charger  ")




#script
cat("   parser  ")

parser <- ArgumentParser(description= 'recup membres clusters of interest')

parser$add_argument('--input_taxResult', '-it', help= 'tab_taxResult_tax_per_contig (metaeuk)')
parser$add_argument('--input_cov', '-ic', help= 'stat dataframe')
parser$add_argument('--input_CG', '-icg', help= '%CG')
parser$add_argument('--input_Busco', '-ib', help= 'Busco result')
parser$add_argument('--input_depth', '-id', help= 'depth median per contigs')


parser$add_argument('--output_Plot', '-o', help= 'CG depth plot')
parser$add_argument('--output_Plot_jpg', '-op', help= 'CG depth plot')
parser$add_argument('--output_Plot_inter', '-oi', help= 'same plot but interactive')
parser$add_argument('--output_full_tab', '-ot', help= 'dataframe whith all inforamtion')


xargs<- parser$parse_args()

#tableau a charger 
cat("  tableau a charger  ")
tab_taxResult_tax_per_contig <- read.delim(xargs$input_taxResult, header=TRUE, sep="\t", stringsAsFactors=FALSE)
tab_coverage <- read.delim(xargs$input_cov, header=FALSE, comment.char="#")
tab_CG <-  read.delim(xargs$input_CG)
tab_Busco <-read.delim(xargs$input_Busco, header=FALSE, comment.char="#")
tab_depth_median <- read.delim(xargs$input_depth, header=FALSE)



#modif tableau par contig 
cat(" modif tableau par contig ")
tab_taxResult_tax_per_contig$name <- gsub("_", "|", tab_taxResult_tax_per_contig$scaffold)
tab_taxResult_tax_per_contig$name <- sub(".*scaffold", "scaffold", tab_taxResult_tax_per_contig$name )


colnames(tab_taxResult_tax_per_contig)[colnames(tab_taxResult_tax_per_contig) == "scaffold"] <- "Scaffold"



# tableau information sur le coverage 
cat(" tableau information sur le coverage  ")
colnames(tab_coverage) <- c("name", "startpos", "endpos", "numreads", "covbases", "coverage", "meandepth", "meanbaseq", "meanmapq")

# tableau Busco 
cat(" tableau Busco   ")
colnames(tab_Busco) <- c("ID", "statut", "name", "start", "end", "strand", "col7", "col8", "link", "fonction")
tab_Busco$Busco <- "oui"

colnames(tab_depth_median) <- c("name", "depth_median")


# fusion des tableaux 
cat("Fusion des tableau")

tab_taxo_coverage <- merge(tab_coverage, tab_taxResult_tax_per_contig, by = "name", all.x = TRUE)  
tab_taxo_coverage_CG <- merge(tab_CG,tab_taxo_coverage, by = "Scaffold", all.x = TRUE)  
tab_taxo_coverage_CG_median <- merge(tab_taxo_coverage_CG,tab_depth_median,by ="name", all.x = TRUE)
tab_full <- merge(tab_taxo_coverage_CG_median,tab_Busco,by ="name", all.x = TRUE)


# remplacer les NA par non 
tab_full$Busco[is.na(tab_full$Busco)] <- "non"

# Normalisation de la taille des points, par exemple, entre 1 et 5
tab_full$scaled_size <- scales::rescale(log10(tab_full$endpos), to = c(0.1, 15))

# Enregistrer le tableau 
write.table(tab_full, xargs$output_full_tab, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Plot
theme_set(theme_bw())  # pre-set the bw theme.

# Extraire tout ce qui est avant le deuxième underscore
species_name <- sub("^([^_]+_[^_]+)_.*$", "\\1", tab_full$Scaffold[1])

# Construire le titre avec le nom de l'espèce
title <- bquote(paste("Plot GC depth - ", .(species_name)))

# Scatter plot
scatterPlot <- ggplot(tab_full, aes(x = GC_Content..., y = log2(depth_median), colour = superkingdom)) +
  geom_point() + 
  xlab("GC") + 
  ylab("Log2 Median depth") +
  scale_shape_manual(values = c(3, 15)) +  
  scale_color_manual(values = c("Bacteria" = "dodgerblue3", 
                                "Eukaryota" = "chartreuse3", 
                                "Viruses" = "firebrick2", 
                                "NA" = "#cccccc")) +
  geom_point(size = tab_full$scaled_size) +
  theme(legend.position = "none") +
  xlim(10, 90) +       # Limite pour l'axe x
  ylim(0, 15)          # Limite pour l'axe y

# Right boxplot
right_plot <- ggplot(tab_full, aes(x = superkingdom, y = log2(depth_median), colour = superkingdom)) + 
  geom_boxplot(varwidth = F) +
  scale_color_manual(values = c("Bacteria" = "dodgerblue3", 
                                "Eukaryota" = "chartreuse3", 
                                "Viruses" = "firebrick2", 
                                "NA" = "#cccccc")) +
  theme(axis.text.x = element_blank(), 
        axis.title = element_blank(), 
        legend.position = "none", 
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +  
  theme(legend.position = "right") +       
  ylim(0, 15)   

# Upper boxplot
upper_plot <- ggplot(tab_full, aes(x = superkingdom, y = GC_Content..., colour = superkingdom)) + 
  geom_boxplot(varwidth = F) +
  scale_color_manual(values = c("Bacteria" = "dodgerblue3", 
                                "Eukaryota" = "chartreuse3", 
                                "Viruses" = "firebrick2", 
                                "NA" = "#cccccc")) +
  theme(axis.text.y = element_blank(), 
        axis.title = element_blank(), 
        legend.position = "none", 
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  coord_flip() +
  ggtitle(title)  +
  ylim(10, 90)

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
ggsave(filename = paste0(xargs$output_Plot), plot = Lb, width = 12, height = 10.08, dpi = 2400, device = "svg")
ggsave(filename = paste0(xargs$output_Plot_jpg), plot = Lb, width = 12, height = 10.08, dpi = 600)


