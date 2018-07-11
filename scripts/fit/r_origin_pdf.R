#set the time tick in which the simulation start using real data (production and population) 
#This serves to adjust x axis labels in plots
str1<-system("grep startUsingInputsFromTimeTick= ../../src/cms_wheat/Cms_builder.java",intern=T)
str2<-unlist(strsplit(str1,"="))[2]
str3<-unlist(strsplit(str2,";"))[1]
start.real.data<-as.numeric(str3)


#read buyers data
data.buyers<-read.csv("../../output/z_buyers.csv")
data.buyers<-data.buyers[,-1]
buyers<-levels(data.buyers$Name)

data.buyers.firstLines<-data.buyers[1:length(buyers),]
row.index<-order(data.buyers.firstLines[2])

min.C<-data.buyers.firstLines[row.index,6]
max.C<-data.buyers.firstLines[row.index,7]

min.t<-min(unlist(data.buyers[1]))
max.t<-max(unlist(data.buyers[1]))

#read the origin file that will be used to computes exchanges 
data<-read.csv("../../output/z_origin.csv")
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

data.aggregate<-read.csv("../../output/z_aggregate.csv")
data.aggregate<-data.aggregate[,-1]

food<-read.csv("../../data/buyers_Food.csv",)
first.year.of.demand<-as.numeric(unlist(strsplit(names(food)[5],"[.]"))[3])
years<-first.year.of.demand-(data.aggregate$tick/12)[start.real.data]+data.aggregate$tick/12

pdf("figs.pdf",8,12)
par(mfrow=c(4,3))
#layout(matrix(c(1,2,3,4,5,6,7,8,9,10,11,12), nrow = 4, ncol = 3, byrow = TRUE),widths=c(lcm(6),lcm(6),lcm(6)),heights=c(lcm(7),lcm(7),lcm(7),lcm(7)))


data.sessions<-read.csv("../../output/z_sessions.csv")
data.sessions<-data.sessions[,-1]
sessions<-levels(data.sessions$SessionDescription)
min.t<-min(data.sessions[,1])
max.t<-max(data.sessions[,1])


col<-3

#plot(NA,main="Mkt session prices",xlab="time",ylab="price",xlim=c(1992,2014),ylim=c(0,10))
plot(NA,main="Mkt session prices",xlab="time",ylab="price",xlim=c(1975,2014),ylim=c(0,10))

sessions.offered.quantities<-numeric()
producers<-character()
for(i in 1:length(sessions)){
	session_parts<-strsplit(sessions[i]," @ ")
	data.session<-data.sessions[which(data.sessions$SessionDescription==sessions[i]),]
	tmp.session<-session_parts[[1]][1]
	lines(years,data.session[,col],col=which(buyers==tmp.session))
	sessions.offered.quantities<-cbind(sessions.offered.quantities,data.session[,5])
	producers<-c(producers,session_parts[[1]][1])
}

plot(years,data.aggregate$averagePrice,type="l",main="average price",ylab="price",xlab="time",ylim=c(0,10),xlim=c(1992,2014))


producers.idx<-numeric()
for(tmp.producer in producers){
	producers.idx<-c(producers.idx,which(buyers==tmp.producer))
}

plot(NA,main="colors legend",xlab="meaningless",ylab="meaningless",xlim=c(min.t,max.t),ylim=c(0,10))
legend(min.t,10,buyers[producers.idx],text.col=producers.idx)





for(buy in 1:length(buyers)){
	consumption<-colSums(imp.dyn[buy,,])
	sold<-colSums(imp.dyn[,buy,])
	minimum.consumption<-data.buyers$MinimumConsumption[which(data.buyers$Name==buyers[buy])]
	maximum.consumption<-data.buyers$MaximumConsumption[which(data.buyers$Name==buyers[buy])]
	average.consumption<-data.buyers$AverageConsumption[which(data.buyers$Name==buyers[buy])]
	aftc<-c(consumption,sold)
	plot(years,sold,main=buyers[buy],xlim=c(1975,2014),xlab="time",ylab="sold quantity",type="l",ylim=c(0,max(c(max.C,sold))))
	if(length(which(producers==buyers[buy]))>0){
		lines(years,sessions.offered.quantities[,which(producers==buyers[buy])],col="red")
	}
	plot(years,consumption,xlim=c(1992,2014),main=buyers[buy],xlab="time",ylab="bought quantity",type="l",ylim=c(min(minimum.consumption),max(maximum.consumption)))
	lines(years,minimum.consumption,lty=2)
	lines(years,maximum.consumption,lty=2)
	lines(years,average.consumption,lty=3)
	plot(NA,main=buyers[buy],xlab="time",ylab="bought from",ylim=c(0,max(aftc)),xlim=c(1992,2014))
	for(i in 1:length(buyers)){
		lines(years,imp.dyn[buy,i,],col=i)
	}
#	plot(sold,main=buyers[buy],xlab="time",ylab="sold",type="l",col=length(buyers)+2)
}
dev.off()



