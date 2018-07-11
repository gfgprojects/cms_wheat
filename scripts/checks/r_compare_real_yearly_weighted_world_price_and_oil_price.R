#####read non weighted and weighted world average price
y.prices1<-read.csv("../fit/data/e_world_yearly_prices.csv")
#y.prices<-y.prices1[-1,]
y.prices<-y.prices1
weighted.world.yearly.prices.real<-y.prices$WorldPriceWeighted
#normalized.weighted.world.yearly.prices.real<-weighted.world.yearly.prices.real/weighted.world.yearly.prices.real[1]
normalized.weighted.world.yearly.prices.real<-weighted.world.yearly.prices.real/min(weighted.world.yearly.prices.real)

#####compute yearly average oil price

monthly.oil.price.data<-readLines("../../data/monthly_crude_oil_price.csv")
monthly.oil.price.time.char<-unlist(strsplit(monthly.oil.price.data[1],","))
monthly.oil.price.time.char<-monthly.oil.price.time.char[2:length(monthly.oil.price.time.char)]
monthly.oil.price.time.char.mix<-unlist(strsplit(monthly.oil.price.time.char,"[.]"))
monthly.oil.price.time.year<-as.numeric(monthly.oil.price.time.char.mix[seq(1,length(monthly.oil.price.time.char.mix),2)])
monthly.oil.price.time.month<-as.numeric(monthly.oil.price.time.char.mix[seq(2,length(monthly.oil.price.time.char.mix),2)])
monthly.oil.price.time<-monthly.oil.price.time.year+monthly.oil.price.time.month/12-1/24

monthly.oil.price.level.char<-unlist(strsplit(monthly.oil.price.data[2],","))
monthly.oil.price.level<-as.numeric(monthly.oil.price.level.char[2:length(monthly.oil.price.level.char)])
normalized.monthly.oil.price.level<-monthly.oil.price.level/min(monthly.oil.price.level)

food<-read.csv("../../data/buyers_Food.csv",)
first.year.of.demand<-as.numeric(unlist(strsplit(names(food)[5],"[.]"))[3])
staircase.time<-numeric()

#generate staicase series
for(i in (2:length(normalized.weighted.world.yearly.prices.real))){
	staircase.time[length(staircase.time)+1]<-i-2
	staircase.time[length(staircase.time)+1]<-i-1
}

staircase.time<-staircase.time+first.year.of.demand
middle.staircase.points<-seq(0.5,length(normalized.weighted.world.yearly.prices.real))+first.year.of.demand

plot(middle.staircase.points,normalized.weighted.world.yearly.prices.real,type="l")
lines(monthly.oil.price.time,0.9+0.01*monthly.oil.price.level,col=2)

#plot(middle.staircase.points,normalized.weighted.world.yearly.prices.real,type="l")
#lines(middle.staircase.points,normalized.weighted.world.yearly.prices.sim,col=2)
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


#distance<-sum((normalized.weighted.world.yearly.prices.real-normalized.weighted.world.yearly.prices.sim)^2)



