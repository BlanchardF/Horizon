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


#parser 

parser <- ArgumentParser(description= 'recup membres clusters of interest')

parser$add_argument('--input_tab', '-it', help= 'tab with all scaffold information')


parser$add_argument('--output_Plot_inter', '-oi', help= 'interactive plot')



xargs<- parser$parse_args()




#charger le dataframe avec les information sur les contigs 


















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
  theme(legend.position = "right")+
  geom_point(size = tab_full$scaled_size)


# Convertir en plot interactif
interactive_plot <- ggplotly(scatterPlot)

# Afficher le plot interactif
interactive_plot


#enregister

saveWidget(interactive_plot, xargs$output_Plot_inter, selfcontained = TRUE)

