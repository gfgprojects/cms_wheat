##  GENERATE PLOTS FOR COMPARISON OF SIMULATED AND REAL FOOD DATA: EXPORT QUANTITY   ##

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

nonProducersRowIdx<-numeric()
for(i in 1:length(ordered.zones)){
     if(length(which(ordered.zones[i]==producers.names))<1){
	     nonProducersRowIdx<-c(nonProducersRowIdx,i)
     }	
}

fao.exports[nonProducersRowIdx,]<-0


## make plots


years<-seq(1992,2013)
country<-0
for(i in seq(1,nrow(data.food))){
	country<-country+1
	filename<-paste("Plots/ABM/exports ",ordered.zones[i],".jpg",sep="")
	jpeg(filename)
	#country.food.fao<-as.numeric(food.fao[i,])
	#country.food.population<-as.numeric(food.population[i,])
	maxInPlot<-max(c(as.numeric(fao.exports[country,]),as.numeric(exports.from.sim.yearly[country,1:length(years)])))
	minInPlot<-min(c(as.numeric(fao.exports[country,]),as.numeric(exports.from.sim.yearly[country,1:length(years)])))
	plot(years,fao.exports[country,],type="l",main=paste(ordered.zones[i],"exports \n FAO (black) simulations (red)"),ylim=c(minInPlot,maxInPlot))
	lines(years,exports.from.sim.yearly[country,1:length(years)],col=2)
	#lines(years,country.food.population,col="red")
	dev.off()
}

