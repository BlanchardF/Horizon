# 🧬 Horizon

**Horizon** est un projet de génomique comparative visant à identifier les événements de transfert horizontal de gènes au sein de 222 espèces hôtes et parasites collectées au Costa Rica.

---

## 🎯 Objectif

Le projet Horizon vise à :
- Annoter les génomes de l’ensemble des espèces étudiées.
- Réaliser un clustering sur l’ensemble des gènes annotés.
- Identifier les transferts horizontaux de gènes entre les espèces hôtes et parasites.

Ce projet s'inscrit dans le cadre de l'étude des dynamiques évolutives au sein d’un écosystème tropical riche.

---

## 📦 Installation

Cloner ce dépôt :

```bash
git clone git@github.com:BlanchardF/Horizon.git
cd Horizon
```
---

## 📁 Organisation du dépôt

Le projet est structuré en plusieurs répertoires thématiques correspondant aux grandes étapes de l'analyse :

Horizon/
├── Busco/ # Résultats de l'évaluation de complétude des génomes (BUSCO)
├── Clustering/ # Résultats et scripts liés au regroupement des gènes
├── db/ # Bases de données utilisées pour l'annotation (HMM, MMseqs, etc.)
├── Genes_prediction/ # Résultats de la prédiction de gènes 
├── genome/ # Génomes d'entrée des espèces
├── list/ # Listes d'espèces
├── logs/ # Fichiers journaux des traitements et scripts
├── Plot_CG_Depth/ # Résultats pour l'analyse de profondeur de couverture et d'annotation 
├── script/ # Scripts organisés par module
│ ├── Busco/ # Scripts pour lancer et parser les résultats BUSCO
│ ├── Clustering/ # Scripts pour le clustering des gènes
│ ├── Genes_prediction/ # Scripts de prédiction de gènes
│ └── Plot_CG_Depth/ # Visualisations de l'annotation 
├── README.md # Documentation du projet

---

## 🙋 Contact

Pour toute question, suggestion ou collaboration :
**Florian Blanchard** – *[florian.blanchard@unvi-lyon1.fr](mailto:florian.blanchard@unvi-lyon1.fr)* ou *[florian.bd.fb@gmail.com](mailto:florian.bd.fb@gmail.com)* 
