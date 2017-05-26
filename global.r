#nettoyage de l'espace de travail
rm(list=ls())

options(encoding = "UTF-8")

#installation package et librairies

install.packages("wordcloud2", repos='http://cran.us.r-project.org') # générateur de word-cloud 
install.packages("RColorBrewer", repos='http://cran.us.r-project.org') # Palettes de couleurs
library("wordcloud2")
library("RColorBrewer")
library(readr) #librairie import csv



#----Fonction d'importation et nettoyage

impor_netto<-function(CHEMIN, ANNEE){

#importation
marANNEE<-read.table(CHEMIN, sep=";", stringsAsFactors=FALSE,header=TRUE)
#uniformisation des données
marANNEE<-marANNEE[,-18]
#sans les DOM TOM
if ( ANNEE=="1998"|ANNEE=="1999"|ANNEE=="2000"|ANNEE=="2001"|ANNEE=="2002"|ANNEE=="2003"|ANNEE=="2004"|ANNEE=="2005"|ANNEE=="2006"|ANNEE=="2007"|ANNEE=="2008"|ANNEE=="2009")
	{
	marANNEE<-marANNEE[marANNEE$DEPNAIS1!="97"&marANNEE$DEPNAIS1!="98"&marANNEE$DEPNAIS1!="99"&marANNEE$DEPNAIS2!="97"&marANNEE$DEPNAIS2!="98"&marANNEE$DEPNAIS2!="99"
	&marANNEE$DEPMAR!="97"&marANNEE$DEPMAR!="98"&marANNEE$DEPMAR!="99"&marANNEE$DEPDOM!="97"&marANNEE$DEPDOM!="98"&marANNEE$DEPDOM!="99",]
	}

else if ( ANNEE == "2010") 
	{
	marANNEE<-marANNEE[	 marANNEE$DEPNAIS1!="971"&marANNEE$DEPNAIS1!="972"&marANNEE$DEPNAIS1!="973"&marANNEE$DEPNAIS1!="974"&marANNEE$DEPNAIS1!="975"&marANNEE$DEPNAIS1!="977"&marANNEE$DEPNAIS1!="978"&marANNEE$DEPNAIS1!="984"&marANNEE$DEPNAIS1!="985"&marANNEE$DEPNAIS1!="986"&marANNEE$DEPNAIS1!="987"&marANNEE$DEPNAIS1!="988"&marANNEE$DEPNAIS1!="99"
	&marANNEE$DEPNAIS2!="971"&marANNEE$DEPNAIS2!="972"&marANNEE$DEPNAIS2!="973"&marANNEE$DEPNAIS2!="974"&marANNEE$DEPNAIS2!="975"&marANNEE$DEPNAIS2!="977"&marANNEE$DEPNAIS2!="978"&marANNEE$DEPNAIS2!="984"&marANNEE$DEPNAIS2!="985"&marANNEE$DEPNAIS2!="986"&marANNEE$DEPNAIS2!="987"&marANNEE$DEPNAIS2!="988"&marANNEE$DEPNAIS2!="99"
	&marANNEE$DEPMAR!="971"&marANNEE$DEPMAR!="972"&marANNEE$DEPMAR!="973"&marANNEE$DEPMAR!="974"&marANNEE$DEPMAR!="975"&marANNEE$DEPMAR!="977"&marANNEE$DEPMAR!="978"&marANNEE$DEPMAR!="984"&marANNEE$DEPMAR!="985"&marANNEE$DEPMAR!="986"&marANNEE$DEPMAR!="987"&marANNEE$DEPMAR!="988"&marANNEE$DEPMAR!="99"
	&marANNEE$DEPDOM!="971"&marANNEE$DEPDOM!="972"&marANNEE$DEPDOM!="973"&marANNEE$DEPDOM!="974"&marANNEE$DEPDOM!="975"&marANNEE$DEPDOM!="977"&marANNEE$DEPDOM!="978"&marANNEE$DEPDOM!="984"&marANNEE$DEPDOM!="985"&marANNEE$DEPDOM!="986"&marANNEE$DEPDOM!="987"&marANNEE$DEPDOM!="988"&marANNEE$DEPDOM!="99",]
	}
else 
	marANNEE<-marANNEE[	marANNEE$DEPNAIS1!="971"&marANNEE$DEPNAIS1!="972"&marANNEE$DEPNAIS1!="973"&marANNEE$DEPNAIS1!="974" &marANNEE$DEPNAIS1!="975"&marANNEE$DEPNAIS1!="976"&marANNEE$DEPNAIS1!="977"&marANNEE$DEPNAIS1!="978"&marANNEE$DEPNAIS1!="984"&marANNEE$DEPNAIS1!="985"&marANNEE$DEPNAIS1!="986"&marANNEE$DEPNAIS1!="987"&marANNEE$DEPNAIS1!="988"&marANNEE$DEPNAIS1!="99"
	&marANNEE$DEPNAIS2!="971"&marANNEE$DEPNAIS2!="972"&marANNEE$DEPNAIS2!="973"&marANNEE$DEPNAIS2!="974"&marANNEE$DEPNAIS2!="975"&marANNEE$DEPNAIS2!="976"&marANNEE$DEPNAIS2!="977"&marANNEE$DEPNAIS2!="978"&marANNEE$DEPNAIS2!="984"&marANNEE$DEPNAIS2!="985"&marANNEE$DEPNAIS2!="986"&marANNEE$DEPNAIS2!="987"&marANNEE$DEPNAIS2!="988"&marANNEE$DEPNAIS2!="99"
	&marANNEE$DEPMAR!="971"&marANNEE$DEPMAR!="972"&marANNEE$DEPMAR!="973"&marANNEE$DEPMAR!="974"&marANNEE$DEPMAR!="975"&marANNEE$DEPMAR!="976"&marANNEE$DEPMAR!="977"&marANNEE$DEPMAR!="978"&marANNEE$DEPMAR!="984"&marANNEE$DEPMAR!="985"&marANNEE$DEPMAR!="986"&marANNEE$DEPMAR!="987"&marANNEE$DEPMAR!="988"&marANNEE$DEPMAR!="988"&marANNEE$DEPMAR!="99"
	&marANNEE$DEPDOM!="971"&marANNEE$DEPDOM!="972"&marANNEE$DEPDOM!="973"&marANNEE$DEPDOM!="974"&marANNEE$DEPDOM!="975"&marANNEE$DEPDOM!="976"&marANNEE$DEPDOM!="977"&marANNEE$DEPDOM!="978"&marANNEE$DEPDOM!="984"&marANNEE$DEPDOM!="985"&marANNEE$DEPDOM!="986"&marANNEE$DEPDOM!="987"&marANNEE$DEPDOM!="988"&marANNEE$DEPDOM!="99",]

return(marANNEE)
}


#importation et nettoyage des données 
#paramètres : 
#CHEMIN : CHEMIN où se trouve le fichier à importer (-> remplacer les \antislash par des /slash)
#ANNEE : année du jeu de données
mar1998<-impor_netto(CHEMIN="datasets/mariages1998_FR.csv",ANNEE="1998")
mar1999<-impor_netto(CHEMIN="datasets/mariages1999_FR.csv",ANNEE="1999")
mar2000<-impor_netto(CHEMIN="datasets/mariages2000_FR.csv",ANNEE="2000")
mar2001<-impor_netto(CHEMIN="datasets/mariages2001_FR.csv",ANNEE="2001")
mar2002<-impor_netto(CHEMIN="datasets/mariages2002_FR.csv",ANNEE="2002")
mar2003<-impor_netto(CHEMIN="datasets/mariages2003_FR.csv",ANNEE="2003")
mar2004<-impor_netto(CHEMIN="datasets/mariages2004_FR.csv",ANNEE="2004")
mar2005<-impor_netto(CHEMIN="datasets/mariages2005_FR.csv",ANNEE="2005")
mar2006<-impor_netto(CHEMIN="datasets/mariages2006_FR.csv",ANNEE="2006")
mar2007<-impor_netto(CHEMIN="datasets/mariages2007_FR.csv",ANNEE="2007")
mar2008<-impor_netto(CHEMIN="datasets/mariages2008_FR.csv",ANNEE="2008")
mar2009<-impor_netto(CHEMIN="datasets/mariages2009_FR.csv",ANNEE="2009")
mar2010<-impor_netto(CHEMIN="datasets/mariages2010_FR.csv",ANNEE="2010")
mar2011<-impor_netto(CHEMIN="datasets/mariages2011_FR.csv",ANNEE="2011")
mar2012<-impor_netto(CHEMIN="datasets/mariages2012_FR.csv",ANNEE="2012")
mar2013<-impor_netto(CHEMIN="datasets/mariages2013_FR.csv",ANNEE="2013")
mar2014<-impor_netto(CHEMIN="datasets/mariages2014_FR.csv",ANNEE="2014")
mar2015<-impor_netto(CHEMIN="datasets/mariages2015_FR.csv",ANNEE="2015")

#fusion : jeux de données regroupant la totalité des mariages
MARIAGES<-rbind(mar1998,mar1999,mar2000,mar2001,mar2002,mar2003,mar2004,mar2005,mar2006,mar2007,mar2008,mar2009,mar2010,mar2011,mar2012,mar2013,mar2014,mar2015)

#Remplacement "H" et "FE" par Homme et Femme (correspond aux choix du formulaire)
MARIAGES$SEXE1<-replace(MARIAGES$SEXE1, MARIAGES$SEXE1=="M", "Homme")
MARIAGES$SEXE1<-replace(MARIAGES$SEXE1, MARIAGES$SEXE1=="FE", "Femme")

MARIAGES$SEXE2<-replace(MARIAGES$SEXE2, MARIAGES$SEXE2=="M", "Homme")
MARIAGES$SEXE2<-replace(MARIAGES$SEXE2, MARIAGES$SEXE2=="FE", "Femme")

#âge du conjoint 1
MARIAGES$AGE1<-MARIAGES$AMAR-MARIAGES$ANAIS1
#âge conjoint 2
MARIAGES$AGE2<-MARIAGES$AMAR-MARIAGES$ANAIS2



#Jeu de donnée associant le num du dep à son libellé
DEPLIB <- read_delim("datasets/listeDEP.csv", ";", escape_double = FALSE, trim_ws = TRUE)

#Considère slmt les mariages où les conjoints viennent de dep différents
DDEP<-MARIAGES[MARIAGES$DEPNAIS1!=MARIAGES$DEPNAIS2,]

#Considère les mariages où les conjoints viennent du mm dép
MDEP<-MARIAGES[MARIAGES$DEPNAIS1==MARIAGES$DEPNAIS2,]


