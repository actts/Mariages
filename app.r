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
				choices= c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","2A","2B"),
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
			plotOutput('logo'),
			tableOutput('table')
		)
		
	)

)

#output	: partie serveur, gère les objets à retourner	
server<-function(input, output, session) {

#Tranche d'âge selon âge entré
# TAGE<-reactive({
	# if (input$age<30){
		# TAGE<-1
	# }
	# else if (input$age>=30&input$age<50){
		# TAGE<-2
	# }
	# else if (input$age>=50){
		# TAGE<-3
	# }
# })


#A partir d'ici, nous considérerons la personne
#Exemple : Mdata1 > lorsque la personne considérée = variables[1] et le conjoint considéré = variables[2]
#Ddata : jeu de données correspondant au profil avec conjoint dep diff
#Ddata0 > versions correspondant aux genres
Ddata0<-reactive({
	#Données correspondant aux genres âge et département
	if (input$sexe1=="Homme"&input$sexe2=="Homme") {
		Ddata1<-DDEP[DDEP$SEXE1=="M"&DDEP$SEXE2=="M",]
	}  else if ( input$sexe1=="Femme"&input$sexe2=="Femme") {
		Ddata1<-DDEP[DDEP$SEXE1=="FE"&DDEP$SEXE2=="FE",]
	}else if (input$sexe1!=input$sexe2){
		Ddata1<-DDEP[DDEP$SEXE1!=DDEP$SEXE2,]
	}
})

Ddata1<-reactive({
binf<-input$age-5
bsup<-input$age+5
Ddata1<-Ddata0()[Ddata0()$AGE1%in% binf:bsup &Ddata0()$DEPNAIS1==input$dep,]
})

Ddata2<-reactive({
binf<-input$age-5
bsup<-input$age+5
Ddata2<-Ddata0()[Ddata0()$AGE2%in% binf:bsup &Ddata0()$DEPNAIS2==input$dep,]
})

#Mdata : jeu de données correspondant au profil avec conjoint meme dep
Mdata0<-reactive({
	#Données dep et sexes
	if (input$sexe1=="Homme"&input$sexe2=="Homme") {
		Mdata<-MDEP[MDEP$DEPNAIS1==input$dep&MDEP$SEXE1==MDEP$SEXE2&MDEP$SEXE1=="M",]
	} else if ( input$sexe1=="Femme"&input$sexe2=="Femme") {
		Mdata<-MDEP[MDEP$DEPNAIS1==input$dep&MDEP$SEXE1==MDEP$SEXE2&MDEP$SEXE1=="FE",]
	} else if (input$sexe1!=input$sexe2){
		Mdata<-MDEP[MDEP$DEPNAIS1==input$dep&MDEP$SEXE1!=MDEP$SEXE2,]
	}
})

Mdata1<-reactive({
binf<-input$age-5
bsup<-input$age+5
Mdata1<-Mdata0()[Mdata0()$AGE1 %in% binf:bsup,]
})

Mdata2<-reactive({
binf<-input$age-5
bsup<-input$age+5
Mdata2<-Mdata0()[Mdata0()$AGE2 %in% binf:bsup,]
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
		TABLE[1,2]<-1
		TABLE[2,1]<-"correspondant"
		TABLE[2,2]<-1
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
		
		Terms<-TABLE[order(TABLE[,2],decreasing=FALSE),] 
		}	
})

 # brewer.pal(8, "Spectral")
output$table<-renderTable({Mterms()})
 
output$nuage <- renderWordcloud2({
	wordcloud2(data=head(Mterms(),20), size = 1, minSize = 2, gridSize = 0,
		fontFamily = 'Calibri', fontWeight = 'bold',
		color=c("#FFFFFF","#FFFFFF","#0778FF","#0778FF","#8FFFB2","#8FFFB2","#10F156","#10F156","#F4FF6C","#F4FF6C","#FFC536","#FFC536","#FFA600","#FFA600","#FF6400","#FF6400","#FF3E7E","#FF3E7E"), backgroundColor = "#40c2cc",
		minRotation = -pi, maxRotation = pi, shuffle = TRUE,
		rotateRatio = 0.4, shape = 'triangle', ellipticity = 0.65,
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

    return(list(src = "images/logo.png"))	
	})
}	



shinyApp(ui = ui, server= server)
