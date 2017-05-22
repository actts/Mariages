# Mariages

Afin de réaliser cette application R interactive, nous avons utilisé R shiny."Shiny" est un package développé par R Studio. Il permet de créer des pages et applications web interactives et d'y intégrer toutes les actions disponibles avec le langage R.
Nous avons décidé de se baser sur le recensement des mariages en France métropolitaine de 1998 à 2015. Attention, afin de réaliser ces observations nous avons considéré une personne mariée et non plus un mariages comme individu. L'utilisateur renseigne son genre, ce qu'il recherche et le département d'où il vient. Il est alors possible de connaître en fonction des mariages passés les départements d'origine les plus probables de leur "âme-soeur" sous forme de nuage de point. Cette conclusion est tirée des observations faites sur les personnes ayant le même profil. Naturellement, les couples proviennent majoritairement du même département. Ainsi, le nuage de point ne prend pas en compte cette donnée. Elle est tout de même affichée dans le texte présent en dessus du graphique, accompagnée d'autres données chiffrées qui comptent les nombres d'observations correspondant au profil et totales.
On observe trois différents script R qui permettent de lancer l'application. Avant toute utilisation, il est important de prendre connaissance de l'ordre d'utilisation de ceux-ci.
## 1- Script 'fonction' et script 'global'
Ce script contient la fonction qui importe et nettoie tous les jeux de données mariages avant utilisation. 
La deuxième partie permet l'import de toutes les données, librairies et packages. 
Remarque : penser à adapter le chemin où se situe vos données dans la procédure setwd.
## 2- Script 'App' 
Ce dernier permet la création de l'application R. On peut y distinguer deux parties qui échangent entre elles : serveur et ui (interface utilisateur).

