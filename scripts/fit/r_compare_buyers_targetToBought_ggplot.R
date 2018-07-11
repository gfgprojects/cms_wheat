library(ggplot2)
library(tikzDevice)
library(scales)

##  GENERATE PLOTS FOR COMPARISON OF SIMULATED AND REAL FOOD DATA: BOUGHT QUANTITY   ##

## need the compute values from simulation output script to be run before this script
source("r_compute_bought_import_export_from_simulations.R")





#read real data used as input in the ABM

pathToAbmInputs<-"../../data/"
data.food<-read.csv(paste(pathToAbmInputs,"buyers_Food.csv",sep=""))
data.feed<-read.csv(paste(pathToAbmInputs,"buyers_Feed.csv",sep=""))
data.seed<-read.csv(paste(pathToAbmInputs,"buyers_Seed.csv",sep=""))
data.misc<-read.csv(paste(pathToAbmInputs,"buyers_Misc.csv",sep=""))
data.producers<-read.csv(paste(pathToAbmInputs,"producers.csv",sep=""))
producers.in.sim<-as.character(data.producers[,1])

target.demand1<-data.food[,5:ncol(data.food)]+data.feed[,5:ncol(data.feed)]+data.seed[,5:ncol(data.seed)]+data.misc[,5:ncol(data.misc)]

ordered.zones<-as.character(data.food[order(as.character(data.food[,1])),1])
target.demand<-target.demand1[order(as.character(data.food[,1])),]


# read FAO data 

data.food.fao<-read.csv("../generate_inputs/data/buyersC_Food.csv")
data.feed.fao<-read.csv("../generate_inputs/data/buyersC_Feed.csv")
data.seed.fao<-read.csv("../generate_inputs/data/buyersC_Seed.csv")
data.pwo.fao<-read.csv("../generate_inputs/data/buyersC_ProcessingWasteOther.csv")
data.production.fao<-read.csv("../generate_inputs/data/producersC.csv")
data.sv.fao<-read.csv("../generate_inputs/data/buyersC_Stock_Variation.csv")

food.fao<-data.food.fao[,5:ncol(data.food.fao)]
feed.fao<-data.feed.fao[,5:ncol(data.feed.fao)]
seed.fao<-data.seed.fao[,5:ncol(data.seed.fao)]
pwo.fao<-data.pwo.fao[,5:ncol(data.pwo.fao)]
production.fao<-data.production.fao[10:ncol(data.production.fao)]
sv.fao<-data.sv.fao[6:ncol(data.sv.fao)]
demand.to.remove<-production.fao+sv.fao
for(i in 1:nrow(demand.to.remove)){
	if(length(which(producers.in.sim==as.character(data.production.fao[i,1])))>0){
		demand.to.remove[i,]<-0
	}
}



demand.fao1<-food.fao+feed.fao+seed.fao+pwo.fao-demand.to.remove
#demand.fao1<-food.fao+feed.fao+seed.fao+pwo.fao-removedDemand
ordered.zones.fao<-as.character(data.food.fao[order(as.character(data.food.fao[,1])),1])
demand.fao<-demand.fao1[order(as.character(data.food.fao[,1])),]


## make plots
#food<-read.csv("../../data/buyers_Food.csv",)
first.year.of.demand<-as.numeric(unlist(strsplit(names(data.food)[5],"[.]"))[3])
last.year.of.demand<-as.numeric(unlist(strsplit(names(data.food)[ncol(data.food)],"[.]"))[3])

years<-seq(first.year.of.demand,last.year.of.demand)
country<-0
for(i in seq(1,nrow(data.food))){
#for(i in 1:1){
	country<-country+1
	#country.food.fao<-as.numeric(food.fao[i,])
	#country.food.population<-as.numeric(food.population[i,])

	country.data.to.plot<-data.frame(time=years,sim.target=as.numeric(target.demand[country,]),sim.bought=as.numeric(consumption.from.sim.yearly[country,1:length(years)]),fao=as.numeric(demand.fao[country,]))
	for.y.range<-as.numeric(c(target.demand[country,],consumption.from.sim.yearly[country,1:length(years)],unlist(demand.fao[country,])))

#start plot
	a<-ggplot(data=country.data.to.plot)+theme_bw()+coord_cartesian(xlim=c(1992,2013),ylim=c(min(for.y.range),max(for.y.range))) +
		labs(title=ordered.zones[i],subtitle="\\hskip4mm $\\spadesuit$ FAO \\hskip4mm $\\color{red}\\clubsuit$ simulation \\hskip4mm \\color{green!55!black} \\huge \\raisebox{-0.8mm}{$\\bullet$} \\normalsize \\color{black} target",y="Bought quantities (tons)") +
		theme(axis.text.y = element_text(angle = 90,hjust=0.5),panel.border = element_rect(color="black",size=1),panel.grid.major=element_line(colour="black",linetype="dotted"),plot.title = element_text(hjust = 0.5))
	a<-a+ scale_y_continuous(labels = scientific) 
	#plot lines
	a <-a + geom_line(aes(x=time,y=sim.target),col="green4")
	a <-a + geom_line(aes(x=time,y=fao),col="black")
	a <-a + geom_line(aes(x=time,y=sim.bought),col="red")
	#plot symbols along the lines
	a<-a+geom_text(aes(x=time,y=sim.bought), label="$\\clubsuit$",size=3,colour="red", data=subset(country.data.to.plot, seq(1,length(country.data.to.plot$time)) %% 2 ==1 ))
	a<-a+geom_text(aes(x=time,y=fao), label="$\\spadesuit$",size=3,colour="black", data=subset(country.data.to.plot, seq(1,length(country.data.to.plot$time)) %% 2 ==1 ))
	a<-a+geom_text(aes(x=time,y=sim.target), label="$\\bullet$",size=5,colour="green4", data=subset(country.data.to.plot, seq(1,length(country.data.to.plot$time)) %% 2 ==1 ))



	#	filename<-paste("Plots/ABM/bought ",ordered.zones[i],".jpg",sep="")
	cname<-paste("bought_",paste(unlist(strsplit(ordered.zones[i]," ")),sep="",collapse=""),sep="")
	fileName<-paste(cname,".tex",sep="")
	toFileFlag<-T
	if(toFileFlag){
		tikz(fileName,width=4,height=3.3,standAlone=T)
	}
	plot(a)

	#compile the tex file to obtain pdf file
	if(toFileFlag){
		dev.off()
		system(paste("pdflatex",fileName))
		system(paste("mv ",cname,".pdf"," Plots/ABM/",sep=""))
		system(paste("rm ",cname,".*",sep=""))

	}     
	#	jpeg(filename)
	#	plot(a)
	#	dev.off()
}

