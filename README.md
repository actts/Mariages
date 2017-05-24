# Mariages


Pour ceux qui découvriraient ce script par eux même, une explication s'impose. Nous sommes Bittle, une start-up spécialisée en outils de reporting et de dashbord.
Plus récemment, nous avons mis en place la plateforme DataRendezVous™, véritable réseau social de la donnée sur laquelle se rencontrent de nombreux contributeurs.
(Pour plus d'informations : [ici](http://www.bittle-solutions.com/?lang=fr_fr)). 
Afin de mettre en avant l'open data, nous avons choisi de développer une application web en se basant seulement sur des données ouvertes.
Vous trouverez le résultat de l'étude en suivant ce [lien](http://5.39.72.157:3838/mariages/).


Afin de réaliser cette application R interactive, nous avons utilisé R shiny."Shiny" est un package développé par R Studio. Il permet de créer des pages et applications web interactives et d'y intégrer toutes les actions disponibles avec le langage R.
Nous avons décidé de se baser sur le recensement des mariages en France métropolitaine de 1998 à 2015. Attention, afin de réaliser ces observations nous avons considéré une personne mariée et non plus un mariages comme individu. L'utilisateur renseigne son genre, ce qu'il recherche et le département d'où il vient. Il est alors possible de connaître en fonction des mariages passés les départements d'origine les plus probables de leur "âme-soeur" sous forme de nuage de point. Cette conclusion est tirée des observations faites sur les personnes ayant le même profil. Naturellement, les couples proviennent majoritairement du même département. Ainsi, le nuage de point ne prend pas en compte cette donnée. Elle est tout de même affichée dans le texte présent en dessus du graphique, accompagnée d'autres données chiffrées qui comptent les nombres d'observations correspondant au profil et totales.
On observe trois différents script R qui permettent de lancer l'application. Avant toute utilisation, il est important de prendre connaissance de l'ordre d'utilisation de ceux-ci.
## 1- Script 'global'
Ce script contient la fonction qui importe et nettoie tous les jeux de données mariages avant utilisation. 
La deuxième partie permet l'import de toutes les données et librairies et packages ainsi que les possibles modifications sur les données. 

## 2- Script 'App' 

Ce dernier permet la création de l'application R. On peut y distinguer deux parties qui échangent entre elles : serveur et ui (interface utilisateur).
Ces derniers sont créés puis appelés par la fonction shinyApp. 

Remarque : penser à adapter le chemin où se situe vos données dans la procédure setwd.

## 3- Description détaillée des méthodes 


### 3.1 Utilisation des données 

Afin de développer cette application, il a été nécessaire de préparer et importer les données.
Il est important de faire un point sur l'utilisation des données afin de comprendre ce script. 
En effet, les données considèrent une ligne par mariage alors que pour l'application a été considéré considéré les personnes mariées.
Nous avons dans un premier temps séparé les jeux de données en deux catégories : 

-> Les données concernant les mariages où les conjoints sont originaires du même département

-> Les données concernant les mariages où les conjoints sont originaires de départements différents

À partir de ce point, les jeux de données sont dupliqués afin de considérer dans un premier temps le conjoint 1 et dans un second temps le conjoint 2. 
On sélectionne ensuite les caractéristiques voulus sur le conjoint 1 dans le jeu 1 et de la même manière sur le conjoint 2 dans le jeu dupliqué. 
On obtient ainsi quatre échantillons qui regroupent toutes les personnes mariées depuis 1998. La difficulté est seulement de savoir quelles variables considérer pour quel jeu.

### 3.2 Script global

On prépare ainsi les données et leurs importations grâce au script global.
Dans ce dernier, on trouve dans un premier temps les librairies et packages nécessaires.
La fonction permet l'automatisation de l'importation des données. Elle est ensuite appelée pour chaque jeu, ce qui correspond à toutes les différentes années disponibles.

On y fusionne toutes les données afin d'obtenir un unique jeu et on y crée les échantillons MDEP et DDEP (mêmes/différents départements d'origine).
Les découpages en quatre échantillons seront fait dans le script app, car ils dépendent des informations renseignées par l'utilisateur de l'application. 
On importe également les données qui contiennent les correspondances entre le numéro du département et son libellé.

Il faut cependant savoir que lorsqu'une application est hébergé sur le serveur shiny, seul le script app.r est lancé. 
Il a alors été nécessaire d'appeler le script global à partir de ce dernier.
Ainsi, il est appelé une fois lors du lancement de l'application (mise en place de la condition "si DDEP n'existe pas").

### 3.3 Script app 

On passe ainsi à la structure de l'application. Comme décrit précédemment, on observe deux parties distinctes qui communiquent entre elles.
La partir ui et server.

La partie ui concerne tous les 'input'. Un 'input' est un objet que l'utilisateur sera en capacité d'observer sur l'application.
On distingue trois types d'input :
-Les input fixes non interactifs (ex : titres, sous-titres..)
- Les input qui renvoient des informations interactives au serveur en fonction du comportement de l'utilisateur :
On pense ici aux informations renseignées par l'utilisateur dans le formulaire comme l'age, le sexe, le département etc..
- Les input qui affiche les objets créés dans la partie serveur :
On considère les résultats qui sont interactifs et qui dépendent des choix de l'utilisateur.

La deuxième partie serveur concerne les 'output'. Les output sont les objets que l'on crée et qu'on envoie dans la partie ui qui les affiche à son tour.
Ces output sont interactifs et peuvent dépendre des choix de l'utilisateur.

Dans les différents output, remarquons que certains jeux qui dépendent des input sont utilisés à plusieurs reprises. (ex : table DDEP pour le département "13" correspondant à un mariage "FH")
Au lieu de refaire ces étapes à chaque fois, on le fait une fois dans la procédure 'reactive{}'.
En effet, il est nécessaire hors des procédures qui génèrent des output, d'utiliser cette fonction lorsqu'on souhaite utiliser des variables interactifs.

objet<- reactive{}

objet contient le dernier objet déclaré dans reactive. 


Ces objets sont réutilisés dans les autres reactive{} ou output tels que des fonctions. 

On appellera ainsi objet() 

On crée donc tous les output que le souhaite afficher avec la procédure : 

input$[IDobjet] <- render[TYPEobjet] ({
		
		})

Ces output seront appelés dans l'ui grâce à leur IDobjet et avec la procédure :

output[TYPEobjet]('[IDobjet]')
