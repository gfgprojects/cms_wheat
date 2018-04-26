#generate file for inputs in the ABM
#at the end includes the oil price file generation


system("sed -i -e 's/NA/0/g' data/buyersC_Feed.csv")
system("sed -i -e 's/NA/0/g' data/buyersC_Seed.csv")
system("sed -i -e 's/NA/0/g' data/buyersC_ProcessingWasteOther.csv")
system("sed -i -e 's/NA/0/g' data/buyersC_Stock_Variation.csv")


data.producers<-read.csv("data/producersC.csv")
data.buyers<-read.csv("data/buyersC.csv")
data.food1<-read.csv("data/buyersC_Food.csv")
data.food<-read.csv("data/buyersC_FoodSmoothed.csv")
data.feed<-read.csv("data/buyersC_Feed.csv")
data.seed<-read.csv("data/buyersC_Seed.csv")
data.pwo<-read.csv("data/buyersC_ProcessingWasteOther.csv")
data.sv<-read.csv("data/buyersC_Stock_Variation.csv")
data.export<-read.csv("data/buyersC_Export_Quantity.csv")
data.import<-read.csv("data/buyersC_Import_Quantity.csv")


production<-data.producers[,10:ncol(data.producers)]
production1<-production
production_start<-data.producers[,9]
food.pop<-data.buyers$MeanConsumPP*data.buyers[,6:ncol(data.buyers)]*1000
food1<-data.food1[,5:ncol(data.food)]
food<-data.food[,5:ncol(data.food)]
feed<-data.feed[,5:ncol(data.feed)]
seed<-data.seed[,5:ncol(data.seed)]
pwo<-data.pwo[,5:ncol(data.pwo)]
sv<-data.sv[,6:ncol(data.sv)]
sv_start<-data.sv[,5]
export<-data.export[,5:ncol(data.export)]
import<-data.import[,5:ncol(data.import)]

net.import<-import-export

multipliers<-(colSums(production)+colSums(net.import))/colSums(production)
multipliers[1:length(multipliers)]<-1.0
#multipliers[1]<-1.01

modified_production<-production
for(i in 1:nrow(production)){
	modified_production[i,]<-production[i,]*multipliers	
}

production_plus_sv<-production+sv
#correct for world import-export discrepancy
modified_production_plus_sv<-modified_production+0*sv
#ignore correction for world import-export discrepancy
#modified_production_plus_sv<-production+sv

production<-round(modified_production_plus_sv)
#production<-round(modified_production)
#production<-production+sv

production_shifted<-matrix(0,nrow=nrow(production),ncol=ncol(production))
for(i in 1:nrow(production)){
#for(i in 1:3){
	gatherMonth<-data.producers[i,7]
#	gatherMonth<-0   #uncomment to recover 
	alpha<-(12-gatherMonth)/12
	beta<-(1-alpha)
	for(j in 1:ncol(production)){
		powers<-seq(j-1,0)
		production_shifted[i,j]<-sum(1/alpha*(-beta/alpha)^powers*production[i,1:j])+(-beta/alpha)^j*production_start[i]
	}
}

production_shifted_back<-matrix(0,nrow=nrow(production),ncol=ncol(production))
for(i in 1:nrow(production)){
#for(i in 1:1){
	gatherMonth<-data.producers[i,7]
#	gatherMonth<-0   #uncomment to recover 
	alpha<-(12-gatherMonth)/12
	beta<-(1-alpha)
	for(j in 2:(ncol(production)-1)){
#	for(j in 1:1){
		powers<-seq(0,ncol(production)-j)
		production_shifted_back[i,j-1]<-sum(1/beta*(-alpha/beta)^powers*production[i,j:(ncol(production))])+(-alpha/beta)^(ncol(production)+1-j)*production[i,ncol(production)]
	}
}

#demand<-food+feed+seed+pwo-sv
demand<-food+feed+seed+pwo

excess.supply<-production-demand
maximums.excess<-apply(excess.supply,1,max)


file.producers<-readLines("data/producersC.csv")
file.buyers<-readLines("data/buyersC.csv")
file.food<-readLines("data/buyersC_FoodSmoothed.csv")
file.feed<-readLines("data/buyersC_Feed.csv")
file.seed<-readLines("data/buyersC_Seed.csv")
file.pwo<-readLines("data/buyersC_ProcessingWasteOther.csv")
file.sv<-readLines("data/buyersC_Stock_Variation.csv")



production.to.remove<-numeric()

for(i in 1:nrow(production)){
	if(maximums.excess[i]>0){
		production.to.remove<-rbind(production.to.remove,numeric(length=ncol(production)))
	}else{
		production.to.remove<-rbind(production.to.remove,as.numeric(production[i,]))
	}
}


#misc<-pwo-sv-production.to.remove
misc<-pwo-production.to.remove


#write new files
options(scipen=999)
		first.str<-"Country,ISO3.Code,LAT,LON,markets,commodities,GatherMonthMajor,ProdPlusStockVariation.1991,ProdPlusStockVariation.1992,ProdPlusStockVariation.1993,ProdPlusStockVariation.1994,ProdPlusStockVariation.1995,ProdPlusStockVariation.1996,ProdPlusStockVariation.1997,ProdPlusStockVariation.1998,ProdPlusStockVariation.1999,ProdPlusStockVariation.2000,ProdPlusStockVariation.2001,ProdPlusStockVariation.2002,ProdPlusStockVariation.2003,ProdPlusStockVariation.2004,ProdPlusStockVariation.2005,ProdPlusStockVariation.2006,ProdPlusStockVariation.2007,ProdPlusStockVariation.2008,ProdPlusStockVariation.2009,ProdPlusStockVariation.2010,ProdPlusStockVariation.2011,ProdPlusStockVariation.2012,ProdPlusStockVariation.2013"
		write(first.str,"../../data/producers.csv")
		write(file.buyers[1],"../../data/buyers.csv")
		write(file.food[1],"../../data/buyers_Food.csv")
		write(file.feed[1],"../../data/buyers_Feed.csv")
		write(file.seed[1],"../../data/buyers_Seed.csv")
		first.str<-"Country,ISO3.Code,LAT,LON,Value.Misc.1992,Value.Misc.1993,Value.Misc.1994,Value.Misc.1995,Value.Misc.1996,Value.Misc.1997,Value.Misc.1998,Value.Misc.1999,Value.Misc.2000,Value.Misc.2001,Value.Misc.2002,Value.Misc.2003,Value.Misc.2004,Value.Misc.2005,Value.Misc.2006,Value.Misc.2007,Value.Misc.2008,Value.Misc.2009,Value.Misc.2010,Value.Misc.2011,Value.Misc.2012,Value.Misc.2013"
		write(first.str,"../../data/buyers_Misc.csv")
for(i in 1:nrow(production)){
	if(maximums.excess[i]>0){
		str.p1<-paste(data.producers[i,1],data.producers[i,2],data.producers[i,3],data.producers[i,4],data.producers[i,5],data.producers[i,6],data.producers[i,7],production_start[i]+sv_start[i],sep=",")
#		str.p2<-paste(production_shifted[i,],collapse=",")
		str.p2<-paste(production[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/producers.csv",append=T)
		write(file.buyers[i+1],"../../data/buyers.csv",append=T)
		write(file.food[i+1],"../../data/buyers_Food.csv",append=T)
		write(file.feed[i+1],"../../data/buyers_Feed.csv",append=T)
		write(file.seed[i+1],"../../data/buyers_Seed.csv",append=T)
		str.p1<-paste(data.pwo[i,1],data.pwo[i,2],data.pwo[i,3],data.pwo[i,4],sep=",")
		str.p2<-paste(misc[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Misc.csv",append=T)
	}
}
for(i in 1:nrow(production)){
	if(maximums.excess[i]<=0){
		write(file.buyers[i+1],"../../data/buyers.csv",append=T)
		write(file.food[i+1],"../../data/buyers_Food.csv",append=T)
		write(file.feed[i+1],"../../data/buyers_Feed.csv",append=T)
		write(file.seed[i+1],"../../data/buyers_Seed.csv",append=T)
		str.p1<-paste(data.pwo[i,1],data.pwo[i,2],data.pwo[i,3],data.pwo[i,4],sep=",")
		str.p2<-paste(misc[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Misc.csv",append=T)

	}
}
		write("","../../data/producers.csv",append=T)
		write("","../../data/buyers.csv",append=T)
		write("","../../data/buyers_Feed.csv",append=T)
		write("","../../data/buyers_Food.csv",append=T)
		write("","../../data/buyers_Seed.csv",append=T)
		write("","../../data/buyers_Misc.csv",append=T)


#GENERATE OIL PRICE FILE


#read eia (US energy information administration)

data<-readLines("data/monthly_crude_oil_price_world_bank.csv")
time1<-strsplit(data[1],",")
time<-unlist(strsplit(time1[[1]][2:length(time1[[1]])],"\\."))
years<-as.numeric(time[seq(1,length(time),by=2)])
months<-as.numeric(time[seq(2,length(time),by=2)])
time.to.plot<-years+months/12-1/24

line2<-unlist(strsplit(data[2],","))
oilPrice.eia<-as.numeric(line2[2:length(line2)])

first.year.of.demand<-as.numeric(unlist(strsplit(names(data.food)[5],"[.]"))[3])
last.year.of.demand<-as.numeric(unlist(strsplit(names(data.food)[ncol(data.food)],"[.]"))[3])

start.oil.price.position<-which(unlist(time1)==paste(first.year.of.demand-1,".12",sep=""))-1
end.oil.price.position<-which(unlist(time1)==paste(last.year.of.demand,".12",sep=""))-1


write(paste("time",paste(paste(years[start.oil.price.position:end.oil.price.position],".",months[start.oil.price.position:end.oil.price.position],sep=""),collapse=","),sep=","),"../../data/monthly_crude_oil_price.csv")
write(paste("Crude.Oil..petroleum..Price..US.Dollars.per.Barrel.",paste(oilPrice.eia[start.oil.price.position:end.oil.price.position],collapse=","),sep=","),"../../data/monthly_crude_oil_price.csv",append=T)
write("","../../data/monthly_crude_oil_price.csv",append=T)



