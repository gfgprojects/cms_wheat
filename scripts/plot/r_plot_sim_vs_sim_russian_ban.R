library(ggplot2)
library(tikzDevice)
library(grid)



#####read data from Edmondo
y.prices<-read.csv("../fit/data/e_world_yearly_prices.csv")
years<-seq(1992,1992+nrow(y.prices)-1)

#####read data from FAO 
data<-read.csv("../fit/data/wheat_prices.csv",sep=";",na.strings="--")
types<-levels(data$info)
type<-1
data.type<-data[which(as.character(data$info)==types[type]),]
first.year<-as.numeric(substr(as.character(data.type$year[1]),1,4))
price.ts1<-as.numeric(t(data.type[,3:14]))
month.ts1<-first.year+1/24+(5+seq(1,length(price.ts1)))/12
price.ts<-price.ts1[!is.na(price.ts1)]
month.ts<-month.ts1[!is.na(price.ts1)]


#####compute prices from simulation with ban

data.sessions<-read.csv("sim_output_ban_yes/z_sessions.csv")
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

#USA prices
usa.position<-1
for(i in 2:length(sessions)){
	session_parts<-strsplit(sessions[i]," @ ")
	if(session_parts[[1]][1]=="United States of America"){
		usa.position<-i
	}
}
usa.prices<-sessions.prices[,usa.position]

#average prices
tot.exchanged<-rowSums(sessions.quantities)
quantity.shares<-sessions.quantities/tot.exchanged
weighted.prices<-sessions.prices*quantity.shares
weighted.average.price<-rowSums(weighted.prices)
weighted.average.price_1<-weighted.average.price
unweighted.average.price<-rowMeans(sessions.prices)
unweighted.average.price_1<-unweighted.average.price

wapm<-matrix(weighted.average.price,ncol=12,byrow=T)
annual.prices<-rowMeans(wapm)
annual.prices_1<-annual.prices

#####compute prices from simulation without ban

data.sessions<-read.csv("sim_output_ban_no/z_sessions.csv")
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

#USA prices
usa.position<-1
for(i in 2:length(sessions)){
	session_parts<-strsplit(sessions[i]," @ ")
	if(session_parts[[1]][1]=="United States of America"){
		usa.position<-i
	}
}
usa.prices<-sessions.prices[,usa.position]

#average prices
tot.exchanged<-rowSums(sessions.quantities)
quantity.shares<-sessions.quantities/tot.exchanged
weighted.prices<-sessions.prices*quantity.shares
weighted.average.price<-rowSums(weighted.prices)
weighted.average.price_1<-weighted.average.price
unweighted.average.price<-rowMeans(sessions.prices)
unweighted.average.price_1<-unweighted.average.price

wapm<-matrix(weighted.average.price,ncol=12,byrow=T)
annual.prices<-rowMeans(wapm)
annual.prices_2<-annual.prices



##### transform ticks in real time

#read the parameters file
#read the parameters file
str1<-system("grep startUsingInputsFromTimeTick= ../../src/cms_wheat/Cms_builder.java",intern=T)
str2<-unlist(strsplit(str1,"="))[2]
str3<-unlist(strsplit(str2,";"))[1]
start.real.data<-as.numeric(str3)

sim.ticks<-seq(1,max(data.sessions$tick))

time.sim.months<-1992-(sim.ticks/12)[start.real.data]+sim.ticks/12+1/24

time.sim.year<-(time.sim.months[seq(5,length(time.sim.months)-1,12)]+time.sim.months[seq(6,length(time.sim.months)-1,12)])/2
time.sim.year<-c(time.sim.year,time.sim.year[length(time.sim.year)]+1)
start.plot.pos.sim<-which((time.sim.year-0.5)==years[1])





##### start plotting


 
toplot<-data.frame(time=years+0.5,wpw=y.prices$WorldPriceWeighted/min(y.prices$WorldPriceWeighted))
sim.prices.yearly_1<-data.frame(time=time.sim.year[start.plot.pos.sim:(start.plot.pos.sim+length(years)-1+6)],price=annual.prices_1[start.plot.pos.sim:(start.plot.pos.sim+length(years)-1+6)]/min(annual.prices_1[start.plot.pos.sim:(start.plot.pos.sim+length(years)-1)]))
sim.prices.yearly_2<-data.frame(time=time.sim.year[start.plot.pos.sim:(start.plot.pos.sim+length(years)-1+6)],price=annual.prices_2[start.plot.pos.sim:(start.plot.pos.sim+length(years)-1+6)]/min(annual.prices_2[start.plot.pos.sim:(start.plot.pos.sim+length(years)-1)]))
#sim.prices.yearly_1<-data.frame(time=time.sim.year[start.plot.pos.sim:(start.plot.pos.sim+length(years)-1)],price=annual.prices_1[start.plot.pos.sim:(start.plot.pos.sim+length(years)-1)]/min(annual.prices_1[start.plot.pos.sim:(start.plot.pos.sim+length(years)-1)]))
#sim.prices.monthly_1<-data.frame(time=time.sim.months,price=0.5+0.5*weighted.average.price_1/min(annual.prices_1))
sim.prices.monthly_1<-data.frame(time=time.sim.months,price=usa.prices)
#sim.prices.yearly_2<-data.frame(time=time.sim.year,price=0.5+0.5*annual.prices_2/min(annual.prices_2))
#sim.prices.monthly_2<-data.frame(time=time.sim.months,price=0.5+0.5*weighted.average.price_2/min(annual.prices_2))
usa.wheat.data<-data.frame(time=month.ts,wheat=price.ts/80)
#oil.data<-data.frame(time=oil.wheat.data[,2]+month.addendum,oil=oil.wheat.data[,3])
#usa.wheat.data<-data.frame(time=month.ts,wheat=price.ts)
#forylim<-c(smoothed_mean1$y,smoothed_mean2$y,smoothed_mean3$y)
#a<-ggplot(data=toplot)+theme_bw()+coord_cartesian(xlim=c(1,2550),ylim=c(min(forylim)*0.99,max(forylim)*1.01))+labs(y="n. defualts")+theme(panel.border = element_rect(color="black",size=1),panel.grid.major=element_line(colour="black",linetype="dashed"))
a<-ggplot(data=toplot)+theme_bw()+coord_cartesian(xlim=c(1993,2020),ylim=c(1,2.5))+labs(title="Weighted world price",subtitle="\\hskip4mm $\\spadesuit$ sim with ban \\hskip4mm $\\color{red}\\clubsuit$ sim without ban \\hskip4mm \\color{green!55!black} \\huge \\raisebox{-0.8mm}{$\\bullet$} \\normalsize \\color{black} real",y="normalized annual price")+theme(panel.border = element_rect(color="black",size=1),panel.grid.major=element_line(colour="black",linetype="dotted"),plot.title = element_text(hjust = 0.5))

#drawing lines
a<-a+geom_line(aes(x=time,y=wpw),col="green4")
a<-a+geom_line(data=sim.prices.yearly_1,aes(x=time,y=price),col="black",lty=2)
a<-a+geom_line(data=sim.prices.yearly_2,aes(x=time,y=price),col="red",lty=2)
a<-a+geom_line(data=sim.prices.yearly_1[1:22,],aes(x=time,y=price),col="black")
a<-a+geom_line(data=sim.prices.yearly_2[1:22,],aes(x=time,y=price),col="red")
#a<-a+geom_line(data=sim.prices.yearly_2,aes(x=time,y=price),col="red")
#a<-a+geom_line(data=sim.prices.monthly,aes(x=time,y=price),col="green4")

a<-a+geom_text(aes(x=time,y=price), label="$\\clubsuit$",size=3,colour="red", data=subset(sim.prices.yearly_2, seq(1,length(sim.prices.yearly_2$time)) %% 2 ==1 ))
a<-a+geom_text(aes(x=time,y=price), label="$\\spadesuit$",size=3,colour="black", data=subset(sim.prices.yearly_1, seq(1,length(sim.prices.yearly_1$time)) %% 2 ==1 ))
a<-a+geom_text(aes(x=time,y=wpw), label="$\\bullet$",size=5,colour="green4", data=subset(toplot, seq(1,length(toplot$time)) %% 2 ==1 ))



#create white area for legenda

#a<-a+annotate("rect",xmin=1992,xmax=2004.5,ymin=2.25,ymax=2.55,fill="white")

#legenda

#a<-a+annotate("text",x=1993,y=2.5,label="$\\spadesuit$",colour="black",size=3,hjust=0)+annotate("text",x=1994,y=2.5,label="simulation",colour="black",size=4,hjust=0)
#a<-a+annotate("text",x=1993,y=2.35,label="$\\clubsuit$",colour="red",size=3,hjust=0)+annotate("text",x=1994,y=2.35,label="simulation, (flat D)",colour="red",size=4,hjust=0)
#a<-a+annotate("text",x=1993,y=2.35,label="$\\bullet$",colour="green4",size=5,hjust=0)+annotate("text",x=1994,y=2.35,label="real",colour="green4",size=4,hjust=0)



#a<-a+geom_ribbon(aes(x=time,ymin=miny3,ymax=maxy3),alpha=0.3,fill="red")  
#a<-a+geom_text(aes(x=time,y=miny3), label="$\\clubsuit$",alpha=0.3,size=3,colour="red", data=subset(toplot, (time+250) %% 500 == 1))
#a<-a+geom_text(aes(x=time,y=maxy3), label="$\\clubsuit$",alpha=0.3,size=3,colour="red", data=subset(toplot, (time+250) %% 500 == 1))
#a<-a+geom_ribbon(aes(x=time,ymin=miny2,ymax=maxy2),alpha=0.3,fill="blue") 
#a<-a+geom_text(aes(x=time,y=miny2), label="$\\spadesuit$",alpha=0.3,size=3,colour="blue", data=subset(toplot, (time+250) %% 500 == 1))
#a<-a+geom_text(aes(x=time,y=maxy2), label="$\\spadesuit$",alpha=0.3,size=3,colour="blue", data=subset(toplot, (time+250) %% 500 == 1))
#a<-a+geom_ribbon(aes(x=time,ymin=miny1,ymax=maxy1),alpha=0.3,fill="green4")
#a<-a+geom_text(aes(x=time,y=miny1), label="$\\bullet$",alpha=0.3,size=5,colour="green4", data=subset(toplot, (time+250) %% 500 == 1))
#a<-a+geom_text(aes(x=time,y=maxy1), label="$\\bullet$",alpha=0.3,size=5,colour="green4", data=subset(toplot, (time+250) %% 500 == 1))
#a<-a+geom_text(aes(x=time,y=avy3), label="$\\clubsuit$",size=3,colour="red", data=subset(toplot, (time+250) %% 500 == 1))
#a<-a+geom_text(aes(x=time,y=avy2), label="$\\spadesuit$",size=3,colour="blue", data=subset(toplot, (time+250) %% 500 == 1))
#a<-a+geom_text(aes(x=time,y=avy1), label="$\\bullet$",size=5,colour="green4", data=subset(toplot, (time+250) %% 500 == 1))
#a<-a+annotate("rect",xmin=10,xmax=2100,ymin=2.05,ymax=2.25,fill="white")
#a<-a+annotate("text",x=50,y=2.16,label="$\\eta=0.13$, $\\theta=0.05$ ",size=4,hjust=0)
#a<-a+annotate("text",x=50,y=2.1,label="$\\bullet$",colour="green4",size=5,hjust=0)+annotate("text",x=150,y=2.1,label="low $A$",colour="green4",size=4,hjust=0)
#a<-a+annotate("text",x=750,y=2.1,label="$\\spadesuit$",colour="blue",size=3,hjust=0)+annotate("text",x=850,y=2.1,label="mid $A$",colour="blue",size=4,hjust=0)
#a<-a+annotate("text",x=1450,y=2.1,label="$\\clubsuit$",colour="red",size=3,hjust=0)+annotate("text",x=1550,y=2.1,label="high $A$",colour="red",size=4,hjust=0)

fileNameNoExt<-"fig_sim_vs_real_prices_annual_ban"
fileNameExt<-".tex"
fileName<-paste(fileNameNoExt,fileNameExt,sep="")
toFileFlag<-T
if(toFileFlag){
tikz(fileName,width=4,height=3.3,standAlone=T)
}
plot(a)
if(toFileFlag){
dev.off()
system(paste("pdflatex",fileName));
system(paste("mv ",fileNameNoExt,".pdf plots",sep=""))
system(paste("rm ",fileNameNoExt,"*",sep=""))
}




if(F){

b<-ggplot(data=sim.prices.monthly_1)+theme_bw()+coord_cartesian(xlim=c(1993,2013),ylim=c(0.8,4))+labs(y="normalized monthly price")+theme(panel.border = element_rect(color="black",size=1),panel.grid.major=element_line(colour="black",linetype="dotted"))
b<-b+geom_line(aes(x=time,y=price))

#a<-a+geom_text(aes(x=time,y=wpw), label="$\\clubsuit$",size=3,colour="red", data=subset(toplot, (toplot$time+1.5) %% 5 == 1))
b<-b+geom_line(data=sim.prices.monthly_2,aes(x=time,y=price),col="red")

#drawing symbols
b<-b+geom_text(aes(x=time,y=price), label="$\\spadesuit$",size=3, data=subset(sim.prices.monthly_1, seq(29,29+length(sim.prices.monthly_1$time)) %% 30 ==1 ))
b<-b+geom_text(aes(x=time,y=price), label="$\\clubsuit$",size=3,colour="red", data=subset(sim.prices.monthly_2, seq(29,29+length(sim.prices.monthly_2$time)) %% 30 ==1 ))

#create white area for legenda
b<-b+annotate("rect",xmin=1992,xmax=2004.5,ymin=3.5,ymax=4.1,fill="white")

#legenda

b<-b+annotate("text",x=1993,y=3.9,label="$\\spadesuit$",size=3,hjust=0)+annotate("text",x=1994,y=3.9,label="simulation, (steep D)",size=4,hjust=0)
b<-b+annotate("text",x=1993,y=3.65,label="$\\clubsuit$",size=3,colour="red",hjust=0)+annotate("text",x=1994,y=3.65,label="simulation, (flat D)",colour="red",size=4,hjust=0)

fileNameNoExt<-"fig_sim_vs_sim_prices_monthly"
fileNameExt<-".tex"
fileName<-paste(fileNameNoExt,fileNameExt,sep="")
toFileFlag<-T
if(toFileFlag){
tikz(fileName,width=4,height=3,standAlone=T)
}
plot(b)
if(toFileFlag){
dev.off()
system(paste("pdflatex",fileName));
system(paste("mv ",fileNameNoExt,".pdf plots",sep=""))
system(paste("rm ",fileNameNoExt,"*",sep=""))
}




c<-ggplot(data=sim.prices.monthly_1)+theme_bw()+coord_cartesian(xlim=c(1993,2013),ylim=c(0.8,5))+labs(y="normalized monthly price")+theme(panel.border = element_rect(color="black",size=1),panel.grid.major=element_line(colour="black",linetype="dotted"))
c<-c+geom_line(aes(x=time,y=price))
c<-c+geom_line(data=usa.wheat.data,aes(x=time,y=wheat),col="green4")

c<-c+geom_text(aes(x=time,y=price), label="$\\spadesuit$",size=3, data=subset(sim.prices.monthly_1, seq(29,29+length(sim.prices.monthly_1$time)) %% 30 ==1 ))
c<-c+geom_text(aes(x=time,y=wheat), label="$\\bullet$",size=5,colour="green4", data=subset(usa.wheat.data, seq(29,29+length(usa.wheat.data$time)) %% 30 ==1 ))

#create white area for legenda
c<-c+annotate("rect",xmin=1992,xmax=2004.5,ymin=3.5,ymax=4.1,fill="white")

#legenda

c<-c+annotate("text",x=1993,y=3.65,label="$\\bullet$",colour="green4",size=5,hjust=0)+annotate("text",x=1994,y=3.65,label="real USA, monthly",colour="green4",size=4,hjust=0)
c<-c+annotate("text",x=1993,y=3.9,label="$\\spadesuit$",size=3,hjust=0)+annotate("text",x=1994,y=3.9,label="simulation USA, monthly",size=4,hjust=0)
#a<-a+annotate("text",x=1993,y=370,label="$\\spadesuit$",colour="blue",size=3,hjust=0)+annotate("text",x=1994,y=370,label="crude oil \\tiny{average, monthly, barrel}",colour="blue",size=4,hjust=0)

fileNameNoExt<-"fig_sim_vs_real_prices_monthly"
fileNameExt<-".tex"
fileName<-paste(fileNameNoExt,fileNameExt,sep="")

toFileFlag<-T
if(toFileFlag){
tikz(fileName,width=4,height=3,standAlone=T)
}
plot(c)
if(toFileFlag){
dev.off()
system(paste("pdflatex",fileName));
system(paste("mv ",fileNameNoExt,".pdf plots",sep=""))
system(paste("rm ",fileNameNoExt,"*",sep=""))
}

}
