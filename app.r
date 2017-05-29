#setwd("/srv/shiny-server/shinyapp")
setwd("C:/Users/acottais/Documents/Etudes/localRepo/Mariages")

if(exists("DDEP")==FALSE){
library(shiny)
install.packages("shinyjs", repos='http://cran.us.r-project.org')
library(shinyjs)
install.packages("wordcloud2", repos='http://cran.us.r-project.org') # générateur de word-cloud 
library("wordcloud2")
}

appCSS <- "
#loading-content {
  position: absolute;
  background-color: #40c2cc;
  opacity: 0.9;
  z-index: 100;
  left: 0;
  right: 0;
  height: 100%;
  font-weight:bold;
  font-family:calibri, verdana,sans-serif;
  text-align: center;
  color: #FFFFFF;
  font-size: 400%;
}
 div#loading-img{
	 background-color: #40c2cc;
	height : 200px;
 }
"

#input : partie interface utilisateur, gère les différentes entrées de l'utilisateur
ui<-fluidPage(

useShinyjs(),
  inlineCSS(appCSS),
  # Loading message
   div(
     id = "loading-content",
	 "À la recherche de votre âme-soeur..." ,
	div(
		id= "chargmt",
	 "(Chargement...)")),
  
  
  # Code de l'app
  hidden(
  div(
     id = "app-content",


includeCSS("www/style.css"),
tags$head(tags$link(rel="shortcut icon", href="images/favicon.ico")),

			div(id="titre",
			"D'où vient votre",
			span( class="rose", "âme-soeur"),
			"?"),
					
	sidebarLayout(
		 
		sidebarPanel(
			radioButtons(
				inputId="sexe1",
				label="Vous êtes ?",
				choices=c("Homme","Femme"),
				selected=NULL,
				inline=FALSE
			),
			radioButtons(
				inputId="sexe2",
				label="Vous cherchez ?",
				choices=c("Femme","Homme"),
				selected=NULL,
				inline=FALSE
			),
			selectInput(
				inputId="dep",
				label="De quel département êtes vous originaire ?",
				choices= c(rep(1:19),"2A","2B",rep(21:95) ),
				selected=NULL,
				multiple=FALSE,
				selectize=TRUE
			),
			sliderInput(
				"age",
                "À quel âge aimeriez-vous vous marier ?",
                min = 18,  max = 99, value = 35
			)
		),
		
		mainPanel(	
			#pourcentage du mm dep
			div(id="text1",
				span(class="rose",
					textOutput('text1')),
				"  des personnes qui vous ressemblent ont un conjoint originaire du même département. Si ce n'est pas le cas, voici les départements les ",
				span(class="rose",
					"plus représentés  "),
				" :"),
			
			
			#wordcloud
			wordcloud2Output(outputId='nuage')
			),
		),
		fluidRow(
			div(id="blocres",
					#icone
					imageOutput('imagecouple'),

					#age moyen du conjoint
					div(id="tage",
						"Age moyen du conjoint :",
						span(class="rose",
						textOutput('text2'))
						),

					#pourcentage de lieux mariage dans le dep
					div(id="text3",
						span(class="rose", textOutput("depmar")),
						"% des personnes correspondant à votre profil se marient en ",
						span(class="rose", textOutput("dep"))
						)
				)
			),
		fluidRow(
		
					#nb obs pour le cas considéré
					div(id="textfin",
						"Observation réalisée grâce à un recensement de",
						span(class="rose", textOutput("nbobs")),
						" personnes mariées (sur ",
						span(class="rose", "7139436"),
						"individus.)"
					),

					#imageOutput("logo")
					tags$a(plotOutput("logo"),href="https://www.datarendezvous.com/")
				
			)	
		)
	)
)

#output	: partie serveur, gère les objets à retourner	
server<-function(input, output, session) {
output$load <- renderImage({

    return(list(src = "images/logodrdv.png"))	
	}, deleteFile = FALSE)


if(exists("DDEP")==FALSE){
source(file="global.r")
}

  # Cache le message chargement lorsque les données sont importées
  hide(id = "loading-content", anim = TRUE, animType = "fade")    

  
Ddata1<-reactive({
binf<-input$age-2
bsup<-input$age+2
Ddata1<-DDEP[DDEP$AGE1%in% binf:bsup &DDEP$DEPNAIS1==input$dep&DDEP$SEXE1==input$sexe1&DDEP$SEXE2==input$sexe2,]
})

Ddata2<-reactive({
binf<-input$age-2
bsup<-input$age+2
Ddata2<-DDEP[DDEP$AGE1%in% binf:bsup &DDEP$DEPNAIS1==input$dep&DDEP$SEXE1==input$sexe2&DDEP$SEXE2==input$sexe1,]
})

#Mdata : jeu de données correspondant au profil avec conjoint meme dep

Mdata1<-reactive({
binf<-input$age-2
bsup<-input$age+2
Mdata1<-MDEP[MDEP$AGE1 %in% binf:bsup&MDEP$SEXE1==input$sexe1&MDEP$SEXE2==input$sexe2&MDEP$DEPNAIS1==input$dep,]
})

Mdata2<-reactive({
binf<-input$age-2
bsup<-input$age+2
Mdata2<-MDEP[MDEP$AGE2 %in% binf:bsup&MDEP$SEXE1==input$sexe1&MDEP$SEXE2==input$sexe2&MDEP$DEPNAIS1==input$dep,]
})


#Mterms : Table finale term/freq > wordcloud
Mterms<-reactive({
		Ddata<-rbind(Ddata1(),Ddata2())
		Mdata<-rbind(Ddata1(),Ddata2())

	#Changement des tables pour correspondre à la table term/freq
		#TABLE1 et 2 : effectif de mariages par département 
		#considère le département de la 1ere puis 2e colonne
		TABLE1<-cbind(names(table(Ddata$DEPNAIS1)),as.matrix(table(Ddata$DEPNAIS1)))
		TABLE2<-cbind(names(table(Ddata$DEPNAIS2)),as.matrix(table(Ddata$DEPNAIS2)))
		colnames(TABLE1)<-c("dep","freq1")
		colnames(TABLE2)<-c("dep","freq2")
		#Fusion : objectif: table des fréquences de mariages par département pour le cas considéré (HF/HH/FF)
		TABLE<-merge(TABLE1,TABLE2, by="dep", all=TRUE)
		if(nrow(TABLE1)==0&nrow(TABLE2)==0){
		TABLE[1,1]<-"Aucun mariage"
		TABLE[1,2]<-3
		TABLE[2,1]<-"Aucun correspondant"
		TABLE[2,2]<-0.5
		Terms<-TABLE[,-3]
		} else  {		
		#Le département considéré est forcément bcp + grand,
		#on lui donne la valeur 0 pour que le wordcloud montre correctement les nuances entre les autres dép.
		TABLE[TABLE$dep==input$dep,2]<-0
		TABLE[TABLE$dep==input$dep,3]<-0
		#Fusion avec DEPLIB : libellés des dep
		TABLE<-merge(DEPLIB,TABLE, by.x="DEP",by.y="dep",all.y=TRUE)
		#passage des valeurs en numérique pour le wordcloud
		TABLE$freq1<-as.numeric(paste(TABLE$freq1))
		TABLE$freq2<-as.numeric(paste(TABLE$freq2))
		#as.numeric afficher des NA lorsque les valeurs sont vides, on les remplace par 0
		TABLE<-replace(TABLE,is.na(TABLE),0)
		#On additionne les fréquence de TABLE1 et 2 une fois uniformisé
		TABLE$freq<-paste(TABLE$freq1+TABLE$freq2)
		#On supprime les 
		TABLE<-TABLE[,-c(1,3,4)]
		TABLE$freq<-as.numeric(paste(TABLE$freq))
		
		Terms<-TABLE[order(TABLE[,2],decreasing=TRUE),] 
		}	
})

 
output$nuage <- renderWordcloud2({
	wordcloud2(data=head(Mterms(),20), size = 1, minSize = 2, gridSize = 0,
		fontFamily = 'Verdana', fontWeight = 'bold',
		color=c("#FFFFFF","#FFFFFF","#0778FF","#0778FF","#8FFFB2","#8FFFB2","#10F156","#10F156","#F4FF6C","#F4FF6C","#FFC536","#FFC536","#FFA600","#FFA600","#FF6400","#FF6400","#FF3E7E","#FF3E7E"), backgroundColor = "#40c2cc",
		minRotation = -pi/4, maxRotation = pi/4, shuffle = TRUE,
		rotateRatio = 0.4, shape = 'circle', ellipticity = 0.65,
		widgetsize = NULL, figPath = NULL, hoverFunction = NULL)
	
	})
	
output$text1<-renderText({
	mdep<-round((nrow(Mdata1())+nrow(Mdata2()))/(nrow(Mdata1())+nrow(Mdata2())+nrow(Ddata1())+nrow(Ddata2()))*100)
	if ( is.na(mdep)){
	paste("-")
	} else
	paste(mdep, " % ", sep="")
	})

output$text2<-renderText({
	#numérateur
	num<-sum(Ddata1()$AGE2)+sum(Ddata2()$AGE1)+sum(Mdata1()$AGE2)+sum(Mdata2()$AGE1)
	#dénominateur
	denom<-nrow(Mdata1())+nrow(Mdata2())+nrow(Ddata1())+nrow(Ddata2())
	age<-round(num/denom)
	if (is.na(age)){
	paste("-")
	} else 
	paste(age, " ans ",sep="")
	
	})


output$depmar<-renderText({
		num<-nrow(Mdata1()[Mdata1()$DEPNAIS1==Mdata1()$DEPMAR,])+nrow(Mdata2()[Mdata2()$DEPNAIS2==Mdata2()$DEPMAR,])+nrow(Ddata1()[Ddata1()$DEPNAIS1==Ddata1()$DEPMAR,])+nrow(Ddata2()[Ddata2()$DEPNAIS2==Ddata2()$DEPMAR,])
		denom<-nrow(Mdata1())+nrow(Mdata2())+nrow(Ddata1())+nrow(Ddata2())
		depmar<-round(num/denom*100)
 if (is.na(depmar)){
		paste("-")
	} else 
		paste(depmar)
		
})

output$dep<-renderText({

	dep<-DEPLIB[DEPLIB$DEP==input$dep,2]
	paste(dep)
})

output$nbobs<-renderText({
	return<-nrow(Ddata1())+nrow(Ddata2())
	})

output$logo <- renderImage({

    return(list(src = "images/logodrdv.png"))	
	}, deleteFile = FALSE)
	
	
	
	
	
	
output$imagecouple <- renderImage({
    if (is.null(input$sexe1)){
		return(NULL)
	} else {
		img<-paste("images/",input$sexe1,"-",input$sexe2,".png", sep="")
		return(list(
			src=img,
			filetype = "image/png",
			alt="couple"
		)) }
}, deleteFile = FALSE)


show("app-content")

}	



shinyApp(ui = ui, server= server)
