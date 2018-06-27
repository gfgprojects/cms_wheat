#generate file for inputs in the ABM
#it also includes the oil price file generation (at the end)



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

write(demand.multipliers,"demandMultipliers.csv",ncolumns=1)


file.producers<-readLines("data/producersC.csv")
file.buyers<-readLines("data/buyersC.csv")
file.food1<-readLines("data/buyersC_Food.csv")
file.food<-readLines("data/buyersC_FoodSmoothed.csv")
file.feed<-readLines("data/buyersC_Feed.csv")
file.seed<-readLines("data/buyersC_Seed.csv")
file.pwo<-readLines("data/buyersC_ProcessingWasteOther.csv")
file.sv<-readLines("data/buyersC_Stock_Variation.csv")



