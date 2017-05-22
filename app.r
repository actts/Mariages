#source(file="global.r") 

options(encoding = "UTF-8")

#input : partie interface utilisateur, gère les différentes entrées de l'utilisateur
ui<-fluidPage(
includeCSS("www/test.css"),
	titlePanel("D'où vient votre data-lover ?"),
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
				label="De quel département venez vous ?",
				choices= c(rep(1:95), "2A","2B"),
				#c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","2A","2B"),
				selected=NULL,
				multiple=FALSE,
				selectize=TRUE
			),
		sliderInput(
				"age",
                "Quel âge avez vous ?",
                min = 18,  max = 99, value = 1
			)
		),
		mainPanel(
			#pourcentage du mm dep
			textOutput('text1'),
			#wordcloud
			wordcloud2Output('nuage'),
			#age moyen du conjoint
			textOutput('text2'),
			#pourcentage de lieux mariage dans le dep
			textOutput('text3'),
			#nb obs pour le cas considéré
			textOutput('textfin'),
			plotOutput('logo')
		)
		
	)

)

#output	: partie serveur, gère les objets à retourner	
server<-function(input, output, session) {


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
		fontFamily = 'Calibri', fontWeight = 'bold',
		color=c("#FFFFFF","#FFFFFF","#0778FF","#0778FF","#8FFFB2","#8FFFB2","#10F156","#10F156","#F4FF6C","#F4FF6C","#FFC536","#FFC536","#FFA600","#FFA600","#FF6400","#FF6400","#FF3E7E","#FF3E7E"), backgroundColor = "#40c2cc",
		minRotation = -pi/4, maxRotation = pi/4, shuffle = TRUE,
		rotateRatio = 0.4, shape = 'circle', ellipticity = 0.65,
		widgetsize = NULL, figPath = NULL, hoverFunction = NULL)
	
	})
	
output$text1<-renderText({
	paste(round((nrow(Mdata1())+nrow(Mdata2()))/(nrow(Mdata1())+nrow(Mdata2())+nrow(Ddata1())+nrow(Ddata2()))*100), " % des personnes correspondant à votre profil ont un conjoint originaire du même département. Sinon, les départements les plus représentés sont les suivants :")
	})

output$text2<-renderText({
	#numérateur
	num<-sum(Ddata1()$AGE2)+sum(Ddata2()$AGE1)+sum(Mdata1()$AGE2)+sum(Mdata2()$AGE1)
	#dénominateur
	denom<-nrow(Mdata1())+nrow(Mdata2())+nrow(Ddata1())+nrow(Ddata2())
	age<-round(num/denom)
	
	paste("Age moyen de votre âme soeur :",age)
	})

output$text3<-renderText({
	num<-nrow(Mdata1()[Mdata1()$DEPNAIS1==Mdata1()$DEPMAR,])+nrow(Mdata2()[Mdata2()$DEPNAIS2==Mdata2()$DEPMAR,])+nrow(Ddata1()[Ddata1()$DEPNAIS1==Ddata1()$DEPMAR,])+nrow(Ddata2()[Ddata2()$DEPNAIS2==Ddata2()$DEPMAR,])
	denom<-nrow(Mdata1())+nrow(Mdata2())+nrow(Ddata1())+nrow(Ddata2())
	depmar<-round(num/denom*100)
	paste(depmar, "% des personnes du même profil se marient dans le département dans lequel ils sont nés")
})

output$textfin<-renderText({
	paste("Observation réalisée grâce à un recensement de",nrow(Ddata1())+nrow(Ddata2()), " personnes mariées présentant votre profil sur ", 2*nrow(MARIAGES), "personnes totales.")
	})

output$logo <- renderImage({

    return(list(src = "images/logodrdv.png"))	
	})
}	



shinyApp(ui = ui, server= server)
