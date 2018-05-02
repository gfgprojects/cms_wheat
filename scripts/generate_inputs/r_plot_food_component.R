##  GENERATE PLOTS FOR COMPARISON OF SIMULATED AND REAL FOOD DATA   ##
#*******************************************************************##
#           CHILD 
# launched from "r_generate_smoothed_series_of_food_component.R"
#*******************************************************************

#oldWD<-getwd()
#setwd(paste(getwd(),"/checks",sep=""))

#transforms FAO food data (yearly) in monthly data  
dati_food<-read.csv("data/buyersC_Food.csv")
food.fao<-dati_food[,5:ncol(dati_food)]
monthly_food_matrix<-numeric()
for(i in 1:nrow(dati_food)){
	monthly_food<-numeric()
	for(j in 5:ncol(dati_food)){
		monthly<-dati_food[i,j]/12
		for(z in 1:12){
			monthly_food[length(monthly_food)+1]<-monthly
		}
}
monthly_food_matrix<-rbind(monthly_food_matrix,monthly_food)
}

#computes food target using smoothed real data or population and consumption per capita 
#if(opt=="SMOOTH"){
  dati.food.smooth<-read.csv("data/buyersC_FoodSmoothed.csv")
  food.smooth<-dati.food.smooth[,5:ncol(dati.food.smooth)]
#}else{
  dati.population<-read.csv("data/buyersC.csv")
  food.population<-dati.population[,5]*dati.population[,6:ncol(dati.population)]*1000
#}

food.fao<-food.fao[order(dati_food[,1]),]
food.smooth<-food.smooth[order(dati_food[,1]),]
food.population<-food.population[order(dati_food[,1]),]


#plotting
years<-seq(1992,2013)
country<-0
for(i in seq(1,nrow(dati_food))){
country<-country+1
if(country<10){
	filename<-paste(0,country,"_food_component.jpg",sep="")
}else{
	filename<-paste(country,"_food_component.jpg",sep="")
}
jpeg(filename)
country.food.fao<-as.numeric(food.fao[i,])
country.food.population<-as.numeric(food.population[i,])
country.food.smooth<-as.numeric(food.smooth[i,])
plot(years,country.food.fao,type="l",main=as.character(dati_food[order(dati_food[,1]),1][i]))
lines(years,country.food.smooth,col="red")
lines(years,country.food.population,col=3)
dev.off()
}

# reset original directory:
#setwd(oldWD)
