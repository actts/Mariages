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

On passe ainsi à la structure de l'application. Comme décrit précédemment, on observe deux parties distinctes qui communiquent entre elles en suivant différentes étapes : la partie ui ( et server.
On note un vocabulaire précis concernant certains objets dans une application :
input : objet renseigné par l'utilisateur
output : objet généré puis affiché sur l'interface


1 - L'utilisateur renseigne ses informations

Une partie de l'application est dédiée au formulaire dans lequel l'utilisateur peut renseigner ses informations. 
Différents types d'entrée sont disponibles (choix à sélectionner, à cocher, curseur à placer sur une échelle etc).
Selon le résultat voulu il existe donc un pannel de choix important qui rendent une application interactive.

2 - Le serveur génère les différents output

Les inputs renseignés par l'utilisateurs sont accessibles et utilisés dans la partie serveur. La partie serveur s'occupe de générer tous les output. 
Cette partie peut être utilisée pour réaliser tout type d'action autours des données et a la capacité de gérer des contenus réactif à condition de renseigné leur existance. 
Dans le serveur il est donc possible de créer deux types d'output :
- les output fixes, qui ne dépendent d'aucunes actions
Ces sorties sont souvent des textes, titres, images..
- les output réactifs qui dépendent des input renseignés par l'utilisateurs.

Rshiny propose des procédures afin de générer et de toute sorte d'objets. Il est par exemple possible de sortir du texte, des images, 
Il est important de créer tous les objets interactifs que l'on souhaite afficher en sortie dans la partie serveur.
Il est possible de générer les output fixes directement dans l'ui.


3 - Envoie des ouput dans la partie ui

Les inputs générés sont ensuite envoyés dans la partie ui qui gère l'affichage de tous les différents objets.
Cette partie concerne tous les objets visibles par l'utilisateur de l'application.On appelle les différents objets déclarés dans la partie server grâce à des procédures précises. 
L'application afficher par défaut les objets les uns en dessous des autres, dans l'ordre de leur appel. Il est possible de regrouper les objets dans différentes "boîtes" afin d'avoir un début de mis en page.
Mais il est possible d'aller beaucoup plus loin.

4 - Mise en page de l'application

Il est possible de gérer le style de la page en incluant du CSS à notre application. Il est possible d'inclure ces propriétés directement dans la partie ui, mais nous avons décidé de créer un script à part.
Cela permet de gérer les modifications et les corrections plus facilement. On nomme ce script style.css. 
La difficulté présente ici est de nommer les différents objets, afin de leur attribuer différentes propriétés. 
Dans un développement web basique, le script CSS est rattaché à un script HTMl qui génère le contenu de la page.
Lors de l'écriture d'un script HTML, le développeur attribue lui même les différentes divisions et classes aux différents objets.
Ici, R génère lui tout seul cette page web. Les identifiants ou divisions sont parfois difficiles à réutiliser. 
Il a donc été nécessaire de re-structurer la partie ui tel une page HTML avec des procédures propres aux langages R. 


5 - Pour aller plus loin avec du javascript

Une fois l'application créée, nous avons décidé de corriger un point. L'importation des données et la mise en place des différents objets se sont avérés très long. 
Lors du lancement de l'application la page ne s'affichait pas tant que le chargement complet n'était pas effectué. Nous avons donc décidé de remplacer la page blanche présente lors du chargement par une page un peut plus interactive.
Cette correction était facultative mais améliorait l'expérience de l'utilisateur.
Pour cela nous avons inclus du javascript dans notre application. 
Nous avons ainsi pu afficher la première page et cacher l'application afin de faire patienter l'utilisateur puis de cacher cette page et enfin afficher le contenu.



Il est conseillé de respecter une arborescence précises des fichiers. Deux méthodes sont possibles dans lesquelles les parties ui et server sont au centre des script.
Nous avons choisi la méthode dans laquelle un script nommé app.r contien les deux fonctions ui et server (l'autre méthode consiste à les séparer dans deux scripts différents).
Notre script app.r est donc au centre et il suffit de lancer ce dernier pour faire fonctionner les autres scripts, ou appeler différentes données (jeux de données, images etc)
A partir de ce dernier, il est donc possible d'appeler le script style.css et le script global évoqué précedemment. 


