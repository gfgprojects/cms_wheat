#to be run after a simulation run
#expected result: theoretical and simulated reservation prices coincides

#####compute theoretical reservation price using crude oil price and parameters from Producers class


data<-readLines("../../data/monthly_crude_oil_price.csv")
data.producers<-read.csv("../../output/z_producers.csv")
time1<-strsplit(data[1],",")
time<-unlist(strsplit(time1[[1]][2:length(time1[[1]])],"\\."))
years<-as.numeric(time[seq(1,length(time),by=2)])
months<-as.numeric(time[seq(2,length(time),by=2)])
#months[seq(4,length(months),12)]<-10
time.to.plot<-years+months/12-1/24

line2<-unlist(strsplit(data[2],","))
fuelPrice<-as.numeric(line2[2:length(line2)])

str1<-system("grep crudeOilBarrelPerNHectars= ../../src/cms_wheat/agents/Producer.java",intern=T)
str2<-unlist(strsplit(str1,"="))[2]
str3<-unlist(strsplit(str2,";"))[1]
crudeOilBarrelPerNHectars<-as.numeric(str3)

str1<-system("grep fixUnitCost= ../../src/cms_wheat/agents/Producer.java",intern=T)
str2<-unlist(strsplit(str1,"="))[2]
str3<-unlist(strsplit(str2,";"))[1]
fixUnitCost<-as.numeric(str3)

str1<-system("grep markUp= ../../src/cms_wheat/agents/Producer.java",intern=T)
str2<-unlist(strsplit(str1,"="))[2]
str3<-unlist(strsplit(str2,";"))[1]
markUp<-as.numeric(str3)

productionCosts<-fixUnitCost+fuelPrice*crudeOilBarrelPerNHectars
reservationPrice<-round((1+markUp)*productionCosts,3)


#### extract USA reservation prices from simulation output (all producers have the same reservation price)

data.producers<-read.csv("../../output/z_producers.csv")
sim.reservationPrice<-data.producers[which(data.producers$Name=="United States of America"),9]

# transform simulation ticks in real time
str1<-system("grep startUsingInputsFromTimeTick= ../../src/cms_wheat/Cms_builder.java",intern=T)
str2<-unlist(strsplit(str1,"="))[2]
str3<-unlist(strsplit(str2,";"))[1]
start.real.data<-as.numeric(str3)

sim.ticks<-seq(1,length(sim.reservationPrice))

food<-read.csv("../../data/buyers_Food.csv",)

first.year.of.demand<-as.numeric(unlist(strsplit(names(food)[5],"[.]"))[3])
first.year.of.production<-first.year.of.demand-1

time.sim.months<-first.year.of.demand-1/12-((sim.ticks)/12)[start.real.data]+sim.ticks/12+1/24



plot(time.to.plot,reservationPrice,type="l")
lines(time.sim.months,sim.reservationPrice,col=2)



