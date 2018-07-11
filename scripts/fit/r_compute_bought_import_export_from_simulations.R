
## part of the code is taken from r_origin.R

pathToSimulationOutput<-"../../output/"
#read the parameters file
str1<-system("grep startUsingInputsFromTimeTick= ../../src/cms_wheat/Cms_builder.java",intern=T)
str2<-unlist(strsplit(str1,"="))[2]
str3<-unlist(strsplit(str2,";"))[1]
start.real.data<-as.numeric(str3)

#read buyers data
data.buyers<-read.csv(paste(pathToSimulationOutput,"z_buyers.csv",sep=""))
data.buyers<-data.buyers[,-1]
buyers<-levels(data.buyers$Name)

data.buyers.firstLines<-data.buyers[1:length(buyers),]
row.index<-order(data.buyers.firstLines[2])

min.C<-data.buyers.firstLines[row.index,6]
max.C<-data.buyers.firstLines[row.index,7]

min.t<-min(unlist(data.buyers[1]))
max.t<-max(unlist(data.buyers[1]))

#read the origin file that will be used to computes exchanges 
data<-read.csv(paste(pathToSimulationOutput,"z_origin.csv",sep=""))
data<-data[,-1]
column.split<-strsplit(as.character(data[2][[1]]),":")
tmp.data<-unlist(column.split)
idx<-seq(1,length(tmp.data),by=2)
buyers.col<-tmp.data[idx]
sellers.data.str<-tmp.data[idx+1]
sellers.data<-strsplit(sellers.data.str,";")

ticks<-as.numeric(levels(as.factor(data[,1])))
buyers<-levels(as.factor(buyers.col))

#Three dimensions array: buyers, producers, time
#for each time step this is a matrix in which each row is a buyer and each column is a producer
#Not producing buyers are also included in producers, but there are zeros in their columns
#A row sum gives the total quantity bought by the country
#A column sum gives the total quantity produced by the country
imp.dyn<-array(0,dim=c(length(buyers),length(buyers),length(ticks)),dimnames=list(buyers))
for(i in 1:length(ticks)){
	tmp.idx<-which(data[,1]==ticks[i])
	tmp.buyers.col<-buyers.col[tmp.idx]
	tmp.sellers.data<-sellers.data[tmp.idx]
	tmp.imp.matrix<-matrix(0,ncol=length(buyers),nrow=length(buyers))
	for(buy in tmp.buyers.col){
		row.idx<-which(buyers==buy)
		this.buyer.data<-tmp.sellers.data[which(tmp.buyers.col==buy)]
		for(j in 1:length(this.buyer.data[[1]])){
			#	j<-2
			seller.and.q<-strsplit(this.buyer.data[[1]][j],"\\|")
			seller<-seller.and.q[[1]][1]
			quantity<-as.numeric(seller.and.q[[1]][2])
			col.idx<-which(buyers==seller)
			tmp.imp.matrix[row.idx,col.idx]<-quantity
			imp.dyn[row.idx,col.idx,i]<-quantity
		}
	}

}



data.aggregate<-read.csv(paste(pathToSimulationOutput,"z_aggregate.csv",sep=""))
data.aggregate<-data.aggregate[,-1]

years<-1992-(data.aggregate$tick/12)[start.real.data]+data.aggregate$tick/12

consumption.from.sim<-numeric()
imports.from.sim<-numeric()
sold.from.sim<-numeric()
exports.from.sim<-numeric()

target.consumption.from.sim<-numeric()
for(buy in 1:length(buyers)){
#for(buy in 1:1){
	consumption.matrix<-imp.dyn[buy,,]
	consumption<-colSums(consumption.matrix)
	sold.matrix<-imp.dyn[,buy,]
	sold<-colSums(sold.matrix)
	minimum.consumption<-data.buyers$MinimumConsumption[which(data.buyers$Name==buyers[buy])]
	maximum.consumption<-data.buyers$MaximumConsumption[which(data.buyers$Name==buyers[buy])]
	average.consumption<-data.buyers$AverageConsumption[which(data.buyers$Name==buyers[buy])]
	aftc<-c(consumption,sold)
	consumption.from.sim<-rbind(consumption.from.sim,consumption)
	sold.from.sim<-rbind(sold.from.sim,sold)
	target.consumption.from.sim<-rbind(target.consumption.from.sim,average.consumption)

	consumption.matrix[buy,]<-0
	imports<-colSums(consumption.matrix)
	imports.from.sim<-rbind(imports.from.sim,imports)
	sold.matrix[buy,]<-0
	exports<-colSums(sold.matrix)	
	exports.from.sim<-rbind(exports.from.sim,exports)


#	plot(years,sold,main=buyers[buy],xlim=c(1975,2014),xlab="time",ylab="sold quantity",type="l",ylim=c(0,max(c(max.C,sold))))
#	if(length(which(producers==buyers[buy]))>0){
#		lines(years,sessions.offered.quantities[,which(producers==buyers[buy])],col="red")
#	}
#	plot(years,consumption,xlim=c(1992,2014),main=buyers[buy],xlab="time",ylab="bought quantity",type="l",ylim=c(min(minimum.consumption),max(maximum.consumption)))
#	lines(years,minimum.consumption,lty=2)
#	lines(years,maximum.consumption,lty=2)
#	lines(years,average.consumption,lty=3)
#	plot(NA,main=buyers[buy],xlab="time",ylab="bought from",ylim=c(0,max(aftc)),xlim=c(1992,2014))
#	for(i in 1:length(buyers)){
#		lines(years,imp.dyn[buy,i,],col=i)
#	}
#	plot(sold,main=buyers[buy],xlab="time",ylab="sold",type="l",col=length(buyers)+2)
}


sum.ends<-seq(start.real.data+11,dim(data.aggregate)[1],12)
sum.starts<-sum.ends-11
#sum.starts<-seq(start.real.data,dim(data.aggregate)[1],12)
#sum.ends<-sum.starts+11

target.consumption.from.sim.yearly<-numeric()
consumption.from.sim.yearly<-numeric()
imports.from.sim.yearly<-numeric()
exports.from.sim.yearly<-numeric()
for(i in 1:length(sum.starts)){
target.consumption.from.sim.yearly<-cbind(target.consumption.from.sim.yearly,rowSums(target.consumption.from.sim[,sum.starts[i]:sum.ends[i]]))
consumption.from.sim.yearly<-cbind(consumption.from.sim.yearly,rowSums(consumption.from.sim[,sum.starts[i]:sum.ends[i]]))
imports.from.sim.yearly<-cbind(imports.from.sim.yearly,rowSums(imports.from.sim[,sum.starts[i]:sum.ends[i]]))
exports.from.sim.yearly<-cbind(exports.from.sim.yearly,rowSums(exports.from.sim[,sum.starts[i]:sum.ends[i]]))
}

net.imports.from.sim.yearly<-imports.from.sim.yearly-exports.from.sim.yearly

###################################################################
###################################################################
###################################################################
###################################################################
#exclude the execution from here
if(F){

data.sessions<-read.csv("sim_output/z_sessions.csv")
data.sessions<-data.sessions[,-1]
sessions<-levels(data.sessions$SessionDescription)

par(mfrow=c(2,2))

#plot(NA,main="Mkt session prices",xlab="time",ylab="price",xlim=c(1992,2014),ylim=c(0,10))
plot(NA,main="Mkt session prices",xlab="time",ylab="price",xlim=c(min(years),max(years)),ylim=c(0,10))
grid()
col<-3
prices.start<-numeric()
for(i in 1:length(sessions)){
	session_parts<-strsplit(sessions[i]," @ ")
	data.session<-data.sessions[which(data.sessions$SessionDescription==sessions[i]),]
	lines(years,data.session[,col],col=which(buyers==session_parts[[1]][1]))
	prices.start[i]<-data.session[start.real.data,col]
}
cbind(sessions[order(prices.start)],prices.start[order(prices.start)])

plot(years,data.aggregate$averagePrice,type="l",main="average price",ylab="price",xlab="time",xlim=c(1992,2014),ylim=c(0,10))
grid()
data.session<-data.sessions[which(data.sessions$SessionDescription=="United States of America @ market"),]

plot(years,data.session$MarketPrice,type="l",main="USA session price (black) quantity (red)",xlab="time",ylab="price",xlim=c(1992,2014),ylim=c(0,10))
data.session$QuantityExchanged/min(data.session$QuantityExchanged)
lines(years,10*data.session$QuantityExchanged/min(data.session$QuantityExchanged)-8,type="l",col=2)
lines(years,10*data.session$OfferedQuantity/min(data.session$QuantityExchanged)-8,type="l",col=3)
lines(years,data.session$MarketPrice)
grid()




plot(years,data.session$MarketPrice/data.session$MarketPrice[start.real.data],type="l",col="white",main="USA price sim (black) real (red)",xlab="time",ylab="price",xlim=c(1992,2014),ylim=c(0,4))
grid()
data<-read.csv("sim_output/wheat_prices.csv",sep=";",na.strings="--")
types<-levels(data$info)
type<-1
data.type<-data[which(as.character(data$info)==types[type]),]
first.year<-as.numeric(substr(as.character(data.type$year[1]),1,4))
price.ts<-as.numeric(t(data.type[,3:14]))
month.ts<-first.year+1/24+(5+seq(1,length(price.ts)))/12

lines(month.ts,price.ts/100,col="red")
lines(years,data.aggregate$averagePrice,col=3)



#crude oil monthly prices
data<-readLines("sim_output/monthly_crude_oil_price.csv")
time1<-strsplit(data[1],",")
time<-unlist(strsplit(time1[[1]][2:length(time1[[1]])],"\\."))
years<-as.numeric(time[seq(1,length(time),by=2)])
months<-as.numeric(time[seq(2,length(time),by=2)])
months[seq(10,length(months),12)]<-10
time.to.plot<-years+months/12-1/24

line2<-unlist(strsplit(data[2],","))
fuelPrice<-as.numeric(line2[2:length(line2)])

crudeOilBarrelPerNHectars=0.1
fixUnitCost<-5.0
markUp<--0.8
productionCosts<-fixUnitCost+fuelPrice*crudeOilBarrelPerNHectars
reservationPrice<-(1+markUp)*productionCosts


lines(time.to.plot,reservationPrice,col=4)
}

#### end execution comment


