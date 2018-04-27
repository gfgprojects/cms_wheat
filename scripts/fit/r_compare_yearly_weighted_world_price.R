#####read non weighted and weighted world average price
y.prices1<-read.csv("data/e_world_yearly_prices.csv")
#y.prices<-y.prices1[-1,]
#y.prices<-y.prices1
weighted.world.yearly.prices.real<-y.prices$WorldPriceWeighted
#normalized.weighted.world.yearly.prices.real<-weighted.world.yearly.prices.real/weighted.world.yearly.prices.real[1]
normalized.weighted.world.yearly.prices.real<-weighted.world.yearly.prices.real/min(weighted.world.yearly.prices.real)


#####compute non weighted and weighted world average price from simulation sim_output

data.sessions<-read.csv("../../output/z_sessions.csv")
data.sessions<-data.sessions[,-1]
sessions<-levels(data.sessions$SessionDescription)

data.session<-data.sessions[which(data.sessions$SessionDescription==sessions[1]),]
sessions.prices<-data.session$MarketPrice
sessions.quantities<-data.session$QuantityExchanged
sessions.offered.quantities<-data.session$OfferedQuantity
for(i in 2:length(sessions)){
	session_parts<-strsplit(sessions[i]," @ ")
	data.session<-data.sessions[which(data.sessions$SessionDescription==sessions[i]),]
	sessions.prices<-cbind(sessions.prices,data.session$MarketPrice)
	sessions.quantities<-cbind(sessions.quantities,data.session$QuantityExchanged)
	sessions.offered.quantities<-cbind(sessions.offered.quantities,data.session$OfferedQuantity)
}

str1<-system("grep startUsingInputsFromTimeTick= ../../src/cms_wheat/Cms_builder.java",intern=T)
str2<-unlist(strsplit(str1,"="))[2]
str3<-unlist(strsplit(str2,";"))[1]
start.real.data<-as.numeric(str3)

sessions.prices<-sessions.prices[(start.real.data+1):(start.real.data+nrow(y.prices)*12),]
sessions.quantities<-sessions.quantities[(start.real.data+1):(start.real.data+nrow(y.prices)*12),]
sessions.offered.quantities<-sessions.offered.quantities[(start.real.data+1):(start.real.data+nrow(y.prices)*12),]

#average prices
tot.exchanged<-rowSums(sessions.quantities)
quantity.shares<-sessions.quantities/tot.exchanged
weighted.prices<-sessions.prices*quantity.shares
weighted.average.price<-rowSums(weighted.prices)
unweighted.average.price<-rowMeans(sessions.prices)

wapm<-matrix(weighted.average.price,ncol=12,byrow=T)
weighted.world.yearly.prices.sim<-rowMeans(wapm)

#normalized.weighted.world.yearly.prices.sim<-weighted.world.yearly.prices.sim/weighted.world.yearly.prices.sim[1]
normalized.weighted.world.yearly.prices.sim<-weighted.world.yearly.prices.sim/min(weighted.world.yearly.prices.sim)

staircase.time<-numeric()
staircase.price.real<-numeric()
staircase.price.sim<-numeric()

#generate staicase series
for(i in (2:length(normalized.weighted.world.yearly.prices.real))){
	staircase.time[length(staircase.time)+1]<-i-2
	staircase.time[length(staircase.time)+1]<-i-1
	staircase.price.real[length(staircase.price.real)+1]<-normalized.weighted.world.yearly.prices.real[i-1]
	staircase.price.real[length(staircase.price.real)+1]<-normalized.weighted.world.yearly.prices.real[i-1]
	staircase.price.sim[length(staircase.price.sim)+1]<-normalized.weighted.world.yearly.prices.sim[i-1]
	staircase.price.sim[length(staircase.price.sim)+1]<-normalized.weighted.world.yearly.prices.sim[i-1]

}

food<-read.csv("../../data/buyers_Food.csv",)
first.year.of.demand<-as.numeric(unlist(strsplit(names(food)[5],"[.]"))[3])

staircase.time<-staircase.time+first.year.of.demand
middle.staircase.points<-seq(0.5,length(normalized.weighted.world.yearly.prices.real))+first.year.of.demand

plot(middle.staircase.points,normalized.weighted.world.yearly.prices.real,type="l")
lines(middle.staircase.points,normalized.weighted.world.yearly.prices.sim,col=2)
#lines(staircase.time,staircase.price.real)
#lines(staircase.time,staircase.price.sim,col=2)
for(i in middle.staircase.points){
	lines(c(i-0.5,i-0.5),c(1,2.4),lty=2,col="gray50")
}

#months.to.plot<-seq(from=1993+1/24,by=1/12,length.out=nrow(sessions.offered.quantities))
#zone_position<-8
#plot(months.to.plot,as.numeric(sessions.offered.quantities[,zone_position]),type="l",main=sessions[zone_position],ylab="monthly supply",xlab="time")
#for(i in middle.staircase.points){
#	lines(c(i-0.5,i-0.5),c(0,7*10^7),lty=2,col="gray50")
#}


distance<-sum((normalized.weighted.world.yearly.prices.real-normalized.weighted.world.yearly.prices.sim)^2)



