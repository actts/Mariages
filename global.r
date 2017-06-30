#nettoyage de l'espace de travail

#rm(list=ls())
options(encoding = "UTF-8")


#installation package et librairies


#install.packages("wordcloud2", repos='http://cran.us.r-project.org') # générateur de word-cloud 
#install.packages("RColorBrewer", repos='http://cran.us.r-project.org') # Palettes de couleurs
library("wordcloud2")
library("RColorBrewer")
library(readr) #librairie import csv
library(shiny)

if(exists("DDEP")==FALSE){
DDEP<-read.csv(file="datasets/DDEP.csv")
MDEP<-read.csv(file="datasets/MDEP.csv")
DEPLIB <- read_delim("datasets/listeDEP.csv", ";", escape_double = FALSE)
}
