#to be run after scripts/generate_inputs/r_reduce_number_of_producers_food.R
#expected result: no systematic difference between production and demand

production<-read.csv("../../data/producers.csv")
total_prod<-colSums(production[,8:ncol(production)])

food<-read.csv("../../data/buyers_Food.csv",)
feed<-read.csv("../../data/buyers_Feed.csv",)
seed<-read.csv("../../data/buyers_Seed.csv",)
misc<-read.csv("../../data/buyers_Misc.csv",)

demand<-food[,5:ncol(food)]+feed[,5:ncol(feed)]+seed[,5:ncol(seed)]+misc[,5:ncol(misc)]
total_dem<-colSums(demand)

first.year.of.demand<-as.numeric(unlist(strsplit(names(food)[5],"[.]"))[3])
last.year.of.demand<-as.numeric(unlist(strsplit(names(food)[ncol(food)],"[.]"))[3])
first.year.of.production<-first.year.of.demand-1
last.year.of.production<-last.year.of.demand

plot(seq(first.year.of.production,first.year.of.production-1+length(total_prod)),total_prod,type="l",main="production (black) and demand (red)",xlab="time",ylab="quantity")
lines(seq(first.year.of.demand,first.year.of.production-1+length(total_prod)),total_dem,col=2)

