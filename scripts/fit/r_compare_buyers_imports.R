##  GENERATE PLOTS FOR COMPARISON OF SIMULATED AND REAL FOOD DATA: IMPORT QUANTITY   ##

## need the compute values from simulation output script to be run before this script
#source("r_compute_bought_import_export_from_simulations.R")

dirMain<-unlist(strsplit(getwd(),"fit"))

#read real data from FAOSTAT

pathToFaoOutputs<-paste(dirMain,"generate_inputs/data/",sep="")
data.imports<-read.csv(paste(pathToFaoOutputs,"buyersC_Import_Quantity.csv",sep=""))
data.exports<-read.csv(paste(pathToFaoOutputs,"buyersC_Export_Quantity.csv",sep=""))

fao.imports1<-data.imports[,5:ncol(data.imports)]
fao.exports1<-data.exports[,5:ncol(data.exports)]

ordered.zones<-as.character(data.imports[order(as.character(data.imports[,1])),1])
fao.imports<-fao.imports1[order(as.character(data.imports[,1])),]
fao.exports<-fao.exports1[order(as.character(data.imports[,1])),]

#compute net imports for non exporter


pathToAbmInputs<-"../../data/"
data.producers<-read.csv(paste(pathToAbmInputs,"producers.csv",sep=""))
producers.names<-as.character(data.producers[,1])

producersRowIdx<-numeric()
for(i in 1:length(ordered.zones)){
     if(length(which(ordered.zones[i]==producers.names))>0){
	     producersRowIdx<-c(producersRowIdx,i)
     }	
}

fao.exports[producersRowIdx,]<-0

fao.net.imports<-fao.imports-fao.exports

## make plots


years<-seq(1992,2013)
country<-0
for(i in seq(1,nrow(data.food))){
	country<-country+1
	filename<-paste("Plots/ABM/imports ",ordered.zones[i],".jpg",sep="")
	jpeg(filename)
	#country.food.fao<-as.numeric(food.fao[i,])
	#country.food.population<-as.numeric(food.population[i,])
	maxInPlot<-max(c(as.numeric(fao.net.imports[country,]),as.numeric(imports.from.sim.yearly[country,1:length(years)])))
	minInPlot<-min(c(as.numeric(fao.net.imports[country,]),as.numeric(imports.from.sim.yearly[country,1:length(years)])))
	plot(years,fao.net.imports[country,],type="l",main=paste(ordered.zones[i],"imports \n FAO (black) simulations (red)"),ylim=c(minInPlot,maxInPlot))
	lines(years,imports.from.sim.yearly[country,1:length(years)],col=2)
	#lines(years,country.food.population,col="red")
	dev.off()
}

