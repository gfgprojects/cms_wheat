#generate file for inputs in the ABM
#it also includes the oil price file generation (at the end)


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
#multipliers[3]<-0.96
#multipliers[4]<-0.98
#multipliers[5]<-1.01
#multipliers[6]<-1.01
#multipliers[7]<-0.98

modified_production<-production
for(i in 1:nrow(production)){
	modified_production[i,]<-production[i,]*multipliers	
}

production_plus_sv<-production+sv
#correct for world import-export discrepancy
modified_production_plus_sv<-modified_production+1.0*sv
#ignore correction for world import-export discrepancy
#modified_production_plus_sv<-production+sv

production<-round(modified_production_plus_sv)
#production<-round(modified_production)
#production<-production+sv
aggr.production<-colSums(production)


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

demand<-food+feed+seed+pwo
aggr.dem<-colSums(demand)
demand.multipliers<-(colSums(demand)-colSums(net.import))/colSums(demand)

#for(i in 1:ncol(demand)){
#	food[,i]<-round(food[,i]*demand.multipliers[i])
#	feed[,i]<-round(feed[,i]*demand.multipliers[i])
#	seed[,i]<-round(seed[,i]*demand.multipliers[i])
#	pwo[,i]<-round(pwo[,i]*demand.multipliers[i])
#}

if(F){
demand.multipliers[1:length(demand.multipliers)]<-1

demand.multipliers[1]<-1.0207780
demand.multipliers[2]<-0.9166224
demand.multipliers[3]<-0.9864370
demand.multipliers[4]<-1.0056530
demand.multipliers[5]<-1.0068950
demand.multipliers[6]<-0.9652863
demand.multipliers[7]<-0.9990052
demand.multipliers[8]<-1.0086010 
demand.multipliers[9]<-0.9731543
demand.multipliers[10]<-0.9702577
demand.multipliers[11]<-0.9841147
demand.multipliers[12]<-0.996     #0.9947408
demand.multipliers[13]<-0.932   #0.9477588
demand.multipliers[14]<-0.91  #0.9509480
demand.multipliers[15]<-0.93   #0.9710884
demand.multipliers[16]<-0.998   #1.0059410
demand.multipliers[17]<-0.967
demand.multipliers[18]<-1.0199
demand.multipliers[19]<-0.98
demand.multipliers[20]<-0.987    #0.9853
demand.multipliers[21]<-1.019    #1.0128    1.019
demand.multipliers[22]<-1.0


demand.multipliers[1]<-0.98
demand.multipliers[2]<-0.975
demand.multipliers[3]<-0.975
demand.multipliers[4]<-0.99 
demand.multipliers[5]<-1.006
demand.multipliers[6]<-0.955
demand.multipliers[7]<-0.982 
demand.multipliers[8]<-0.988  
demand.multipliers[9]<-0.944 
demand.multipliers[10]<-0.94
demand.multipliers[11]<-0.96  
demand.multipliers[12]<-0.96 
demand.multipliers[13]<-0.96
demand.multipliers[14]<-0.96
demand.multipliers[15]<-0.96
demand.multipliers[16]<-0.97
demand.multipliers[17]<-0.97
demand.multipliers[18]<-0.97
demand.multipliers[19]<-0.98
demand.multipliers[20]<-0.98
demand.multipliers[21]<-0.98
demand.multipliers[22]<-0.98
}

#se demandFunctionSlopeTuner=15
# e nello smoothing f=0.5
demand.multipliers[1:length(demand.multipliers)]<-1
scaler<-1
demand.multipliers[3]<-1+0.02*scaler   #1994
demand.multipliers[4]<-1+0.04*scaler   #1995
demand.multipliers[5]<-1-0.01*scaler   #1996
demand.multipliers[6]<-1-0.02*scaler   #1997
demand.multipliers[7]<-1+0.01*scaler   #1998
demand.multipliers[8]<-1+0.015*scaler  #1999
demand.multipliers[9]<-1-0.002*scaler  #2000
demand.multipliers[10]<-1.0+0*scaler   #2001
demand.multipliers[11]<-1.0+0*scaler   #2002
demand.multipliers[12]<-1+0.045*scaler #2003
demand.multipliers[13]<-1-0.09*scaler  #2004
demand.multipliers[14]<-1-0.1*scaler   #2005
demand.multipliers[15]<-1-0.1*scaler   #2006
demand.multipliers[16]<-1+0.07*scaler  #2007
demand.multipliers[17]<-1-0.085*scaler #2008
demand.multipliers[18]<-1+0.035*scaler #2009
demand.multipliers[19]<-1+0.043*scaler #2010
demand.multipliers[20]<-1+0.047*scaler #2011
demand.multipliers[21]<-1+0.02*scaler  #2012


for(i in 1:ncol(demand)){
	food[,i]<-round(food[,i]*demand.multipliers[i])
	feed[,i]<-round(feed[,i]*demand.multipliers[i])
	seed[,i]<-round(seed[,i]*demand.multipliers[i])
	pwo[,i]<-round(pwo[,i]*demand.multipliers[i])
}

demand<-food+feed+seed+pwo

#plot(aggr.production,type="o")
#lines(colSums(demand),col=2)
 

excess.supply<-production-demand
maximums.excess<-apply(excess.supply,1,max)


file.producers<-readLines("data/producersC.csv")
file.buyers<-readLines("data/buyersC.csv")
file.food1<-readLines("data/buyersC_Food.csv")
file.food<-readLines("data/buyersC_FoodSmoothed.csv")
file.feed<-readLines("data/buyersC_Feed.csv")
file.seed<-readLines("data/buyersC_Seed.csv")
file.pwo<-readLines("data/buyersC_ProcessingWasteOther.csv")
file.sv<-readLines("data/buyersC_Stock_Variation.csv")



production.to.remove<-numeric()
threshold<-0
for(i in 1:nrow(production)){
	if(maximums.excess[i]>threshold){
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
		first.str<-"Country,ISO3.Code,LAT,LON,Value.Removed.Demand.1992,Value.Removed.Demand.1993,Value.Removed.Demand.1994,Value.Removed.Demand.1995,Value.Removed.Demand.1996,Value.Removed.Demand.1997,Value.Removed.Demand.1998,Value.Removed.Demand.1999,Value.Removed.Demand.2000,Value.Removed.Demand.2001,Value.Removed.Demand.2002,Value.Removed.Demand.2003,Value.Removed.Demand.2004,Value.Removed.Demand.2005,Value.Removed.Demand.2006,Value.Removed.Demand.2007,Value.Removed.Demand.2008,Value.Removed.Demand.2009,Value.Removed.Demand.2010,Value.Removed.Demand.2011,Value.Removed.Demand.2012,Value.Removed.Demand.2013"
		write(first.str,"../../data/buyers_RemovedDemand.csv")
for(i in 1:nrow(production)){
	if(maximums.excess[i]>threshold){
		str.p1<-paste(data.producers[i,1],data.producers[i,2],data.producers[i,3],data.producers[i,4],data.producers[i,5],data.producers[i,6],data.producers[i,7],production_start[i]+sv_start[i],sep=",")
#		str.p2<-paste(production_shifted[i,],collapse=",")
		str.p2<-paste(production[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/producers.csv",append=T)

		write(file.buyers[i+1],"../../data/buyers.csv",append=T)

		str.p1<-paste(data.food[i,1],data.food[i,2],data.food[i,3],data.food[i,4],sep=",")
		str.p2<-paste(food[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Food.csv",append=T)
#		write(file.food[i+1],"../../data/buyers_Food.csv",append=T)

		str.p1<-paste(data.feed[i,1],data.feed[i,2],data.feed[i,3],data.feed[i,4],sep=",")
		str.p2<-paste(feed[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Feed.csv",append=T)	
#		write(file.feed[i+1],"../../data/buyers_Feed.csv",append=T)

		str.p1<-paste(data.seed[i,1],data.seed[i,2],data.seed[i,3],data.seed[i,4],sep=",")
		str.p2<-paste(seed[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Seed.csv",append=T)	
#		write(file.seed[i+1],"../../data/buyers_Seed.csv",append=T)

		str.p1<-paste(data.pwo[i,1],data.pwo[i,2],data.pwo[i,3],data.pwo[i,4],sep=",")
		str.p2<-paste(misc[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Misc.csv",append=T)

		str.p1<-paste(data.pwo[i,1],data.pwo[i,2],data.pwo[i,3],data.pwo[i,4],sep=",")
		str.p2<-paste(production.to.remove[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_RemovedDemand.csv",append=T)

	}
}
for(i in 1:nrow(production)){
	if(maximums.excess[i]<=threshold){
		write(file.buyers[i+1],"../../data/buyers.csv",append=T)

		str.p1<-paste(data.food[i,1],data.food[i,2],data.food[i,3],data.food[i,4],sep=",")
		str.p2<-paste(food[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Food.csv",append=T)
#		write(file.food[i+1],"../../data/buyers_Food.csv",append=T)

		str.p1<-paste(data.feed[i,1],data.feed[i,2],data.feed[i,3],data.feed[i,4],sep=",")
		str.p2<-paste(feed[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Feed.csv",append=T)	
#		write(file.feed[i+1],"../../data/buyers_Feed.csv",append=T)

		str.p1<-paste(data.seed[i,1],data.seed[i,2],data.seed[i,3],data.seed[i,4],sep=",")
		str.p2<-paste(seed[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Seed.csv",append=T)	
#		write(file.seed[i+1],"../../data/buyers_Seed.csv",append=T)


		str.p1<-paste(data.pwo[i,1],data.pwo[i,2],data.pwo[i,3],data.pwo[i,4],sep=",")
		str.p2<-paste(misc[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_Misc.csv",append=T)

		str.p1<-paste(data.pwo[i,1],data.pwo[i,2],data.pwo[i,3],data.pwo[i,4],sep=",")
		str.p2<-paste(production.to.remove[i,],collapse=",")
		str.joined<-paste(str.p1,str.p2,sep=",")
		write(str.joined,"../../data/buyers_RemovedDemand.csv",append=T)

	}
}
		write("","../../data/producers.csv",append=T)
		write("","../../data/buyers.csv",append=T)
		write("","../../data/buyers_Feed.csv",append=T)
		write("","../../data/buyers_Food.csv",append=T)
		write("","../../data/buyers_Seed.csv",append=T)
		write("","../../data/buyers_Misc.csv",append=T)
		write("","../../data/buyers_RemovedDemand.csv",append=T)



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



