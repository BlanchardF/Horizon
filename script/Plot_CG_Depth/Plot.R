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
parser$add_argument('--input_cov_2', '-i2', help= 'stat dataframe')
parser$add_argument('--input_CG', '-icg', help= '%CG')
parser$add_argument('--input_Busco', '-ib', help= 'Busco result')
parser$add_argument('--input_depth', '-id', help= 'depth median per contigs')
parser$add_argument('--input_depth_2', '-id2', help= 'depth median per contigs indiv 2')
parser$add_argument('--input_TE', '-iTE', help= 'TE dataframe')


parser$add_argument('--output_Plot', '-o', help= 'CG depth plot')
parser$add_argument('--output_Plot_jpg', '-op', help= 'CG depth plot')
parser$add_argument('--output_Plot_inter', '-oi', help= 'same plot but interactive')
parser$add_argument('--output_full_tab', '-ot', help= 'dataframe whith all inforamtion')


xargs<- parser$parse_args()

#tableau a charger 
cat("  tableau a charger  ")
tab_taxResult_tax_per_contig <- read.delim(xargs$input_taxResult, header=TRUE, sep="\t", stringsAsFactors=FALSE)
tab_coverage <- read.delim(xargs$input_cov, header=FALSE, comment.char="#")
tab_coverage_2 <- read.delim(xargs$input_cov_2, header=FALSE, comment.char="#")
tab_CG <-  read.delim(xargs$input_CG)
tab_Busco <-read.delim(xargs$input_Busco, header=FALSE, comment.char="#")
tab_depth_median <- read.delim(xargs$input_depth, header=FALSE)
tab_depth_median_2 <- read.delim(xargs$input_depth_2, header=FALSE)
tab_TE <- read.delim(xargs$input_TE, header=FALSE)


#modif tableau par contig 
cat(" modif tableau par contig ")
tab_taxResult_tax_per_contig$name <- gsub("_", "|", tab_taxResult_tax_per_contig$scaffold)
tab_taxResult_tax_per_contig$name <- sub(".*scaffold", "scaffold", tab_taxResult_tax_per_contig$name )


colnames(tab_taxResult_tax_per_contig)[colnames(tab_taxResult_tax_per_contig) == "scaffold"] <- "Scaffold"

#modif tableau CG 
tab_CG$name <- sub("^[^_]*_[^_]*_", "", tab_CG$Scaffold)
tab_CG$name <- gsub("_", "|", tab_CG$name)



# tableau information sur le coverage 
cat(" tableau information sur le coverage  ")
colnames(tab_coverage) <- c("name", "startpos", "endpos", "numreads", "covbases", "coverage", "meandepth", "meanbaseq", "meanmapq")

# tableau information sur le coverage 2
cat(" tableau information sur le coverage 2  ")
colnames(tab_coverage_2) <- c("name", "S2_startpos ", "S2_endpos", "S2_numreads", "S2_covbases", " S2_coverage", "S2_meandepth", "S2_meanbaseq", "S2_meanmapq")


# tableau Busco 
cat(" tableau Busco   ")
colnames(tab_Busco) <- c("ID", "statut", "name", "start", "end", "strand", "col7", "col8", "link", "fonction")
tab_Busco$Busco <- "oui"

# Création du nouveau tableau busco
tab_Busco_summary <- tab_Busco %>%
  filter(name != "") %>%           # Exclure les lignes où "name" est vide
  group_by(name) %>%               # Grouper par la colonne "name"
  summarise(busco = first(Busco),  # Garder la première valeur de Busco
            busco_comptage = n())  # Compter le nombre d'occurrences par "name"



#modif tableau depth median
colnames(tab_depth_median) <- c("name", "depth_median")
colnames(tab_depth_median_2) <- c("name", "S2_depth_median")


#modif TE
colnames(tab_TE)[colnames(tab_TE) == "V1"] <- "name"
tab_TE$TE <- "TE"
# Création du nouveau tableau TE
tab_TE_summary <- tab_TE %>%
  filter(name != "") %>%           # Exclure les lignes où "name" est vide
  group_by(name) %>%               # Grouper par la colonne "name"
  summarise(TE = first(TE),  # Garder la première valeur de Busco
            TE_comptage = n())  # Compter le nombre d'occurrences par "name"




# fusion des tableaux 
cat("Fusion des tableau  ")
tab_coverage_full <- merge(tab_coverage, tab_coverage_2, by = "name", all.x = TRUE)
tab_taxo_coverage <- merge(tab_coverage_full, tab_taxResult_tax_per_contig, by = "name", all.x = TRUE)  
tab_taxo_coverage_CG <- merge(tab_CG,tab_taxo_coverage, by = "name", all.x = TRUE)  
tab_taxo_coverage_CG_median_1 <- merge(tab_taxo_coverage_CG,tab_depth_median,by ="name", all.x = TRUE)
tab_taxo_coverage_CG_median <- merge(tab_taxo_coverage_CG_median_1,tab_depth_median_2,by ="name", all.x = TRUE)
tab_taxo_coverage_CG_median_Busco <- merge(tab_taxo_coverage_CG_median,tab_Busco_summary,by ="name", all.x = TRUE)
tab_full <- merge(tab_taxo_coverage_CG_median_Busco,tab_TE_summary,by ="name", all.x = TRUE)
cat("Fusion des tableau : validé  ")

# Ajouter la colonne "observation"
tab_full <- tab_full %>%
  mutate(observation = case_when(
    !is.na(busco) & !is.na(TE) ~ paste(busco, TE, sep = " + "),  # Si les deux sont remplis
    !is.na(busco) ~ busco,                                      # Si seulement "busco" est rempli
    !is.na(TE) ~ TE,                                            # Si seulement "TE" est rempli
    TRUE ~ NA_character_                                        # Si aucun n'est rempli
  ))


# Normalisation de la taille des points, par exemple, entre 1 et 5
tab_full$scaled_size <- scales::rescale(log10(tab_full$endpos), to = c(0.1, 15))

# Enregistrer le tableau 
write.table(tab_full, xargs$output_full_tab, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

# Plot
theme_set(theme_bw())  # pre-set the bw theme.

# Extraire tout ce qui est avant le deuxième underscore
species_name <- sub("^([^_]+_[^_]+)_.*$", "\\1", tab_CG$Scaffold[1])

# Construire le titre avec le nom de l'espèce
title <- bquote(paste("Plot GC depth - ", .(species_name)))


# Ajouter une colonne pour la transparence
tab_full$alpha <- ifelse(is.na(tab_full$superkingdom), 0.1, 1)


# Créer une colonne catégorielle pour les tailles des points avec des étiquettes
tab_full <- tab_full %>%
  mutate(point_size_category = case_when(
    endpos < 500 ~ "< 500",
    endpos >= 500 & endpos < 2000 ~ "500 - 2000",
    endpos >= 2000 & endpos < 10000 ~ "2000 - 10000",
    endpos >= 10000 & endpos < 30000 ~ "10000 - 30000",
    endpos >= 30000  ~ "> 30000"
  ),
  point_size_category = factor(point_size_category, 
                               levels = c("< 500", "500 - 2000", "2000 - 10000", 
                                          "10000 - 30000", "> 30000"))
  )

# Scatter plot
scatterPlot <- ggplot(tab_full, aes(x = GC_Content..., y = log2(depth_median), colour = superkingdom)) +
  geom_point(aes(size = point_size_category, alpha = alpha)) +
  xlab("GC") + 
  ylab("Log2 Median depth") +
  scale_color_manual(values = c("Bacteria" = "dodgerblue3", 
                                "Eukaryota" = "chartreuse3", 
                                "Viruses" = "firebrick2", 
                                "NA" = "#cccccc")) +
  scale_alpha_identity() +
  scale_size_manual(
    values = c(1, 3, 5, 8, 10),
    name = "Taille des scaffolds"
  ) +
  theme(axis.text.x = element_blank(), 
        axis.title = element_blank(), 
        legend.position = "none", 
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank())+
  xlim(10, 90) +       
  ylim(0, 15)

# Right boxplot
right_plot <- ggplot(tab_full, aes(x = superkingdom, y = log2(depth_median), colour = superkingdom)) + 
  geom_point(aes(size = point_size_category)) +
  geom_boxplot(varwidth = F) +
  scale_color_manual(values = c("Bacteria" = "dodgerblue3", 
                                "Eukaryota" = "chartreuse3", 
                                "Viruses" = "firebrick2", 
                                "NA" = "#cccccc")) +
  scale_size_manual(
    values = c(1, 3, 5, 8, 10),
    name = "Taille des scaffolds \n(en base)"
  ) +
  theme(axis.text.x = element_blank(), 
        axis.title = element_blank(), 
        legend.position = "right", 
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +  
  ylim(0, 15)

# Upper boxplot
upper_plot <- ggplot(tab_full, aes(x = superkingdom, y = GC_Content..., colour = superkingdom)) + 
  geom_point(aes(size = point_size_category)) +
  geom_boxplot(varwidth = F) +
  scale_color_manual(values = c("Bacteria" = "dodgerblue3", 
                                "Eukaryota" = "chartreuse3", 
                                "Viruses" = "firebrick2", 
                                "NA" = "#cccccc")) +
  scale_size_manual(
    values = c(1, 3, 5, 8, 10),
    name = "Taille des scaffolds"
  ) +
  theme(axis.text.y = element_blank(), 
        axis.title = element_blank(), 
        legend.position = "none", 
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  coord_flip() +
  ggtitle(title) +
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