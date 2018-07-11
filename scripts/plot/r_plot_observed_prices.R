library(ggplot2)
library(tikzDevice)
library(grid)


#read data from Edmondo
y.prices<-read.csv("e_world_yearly_prices.csv")
years<-seq(1992,1992+nrow(y.prices)-1)
#plot(years+0.5,y.prices$WorldPrice,type="l")

#read data from FAO 
data<-read.csv("wheat_prices.csv",sep=";",na.strings="--")
types<-levels(data$info)
type<-1
data.type<-data[which(as.character(data$info)==types[type]),]
first.year<-as.numeric(substr(as.character(data.type$year[1]),1,4))
price.ts<-as.numeric(t(data.type[,3:14]))
month.ts<-first.year+1/24+(5+seq(1,length(price.ts)))/12

#read data from indexmundi
oil.wheat.data<-read.csv("crude_oil_wheat_indexmundi.csv")

month.number<-(4+seq(1,nrow(oil.wheat.data)))%%12
month.number[which(month.number==0)]<-12
month.addendum<-(month.number)/12-1/24
time<-oil.wheat.data[,2]+month.addendum

start.year<-1991
end.year<-2013

later.than.start<-which(time>start.year)
before.than.end<-which(time<(end.year+1))

wheat.growing.time.in.months<-6

start.position<-later.than.start[1]-wheat.growing.time.in.months
end.position<-before.than.end[length(before.than.end)]-wheat.growing.time.in.months

#plot(oil.wheat.data[,2]+month.addendum,0.4*(oil.wheat.data[,3]/oil.wheat.data[1,3]-1),type="l")
#lines(oil.wheat.data[,2]+month.addendum,(oil.wheat.data[,4]/oil.wheat.data[1,4]-1),col=2)


tofileflag<-FALSE
#tofileflag<-TRUE

filename<-"fig_prova"
fileextention<-".fig"
completefilename<-paste(filename,fileextention,sep="")
#if(tofileflag){
#xfig(file=completefilename,width=6.0,height=5.0)
#}

#plot(years+0.5,y.prices$WorldPriceWeighted,xlab="dollars",ylab="time",type="l",ylim=c(0,450))
#lines(month.ts,price.ts,col=2)
#lines(oil.wheat.data[,2]+month.addendum,oil.wheat.data[,4],col=3)
#lines(oil.wheat.data[,2]+month.addendum,oil.wheat.data[,3],col=4)
#lines(c(2008.3,2008.3),c(0,450))
#grid()

 
toplot<-data.frame(time=years+0.5,wpw=y.prices$WorldPriceWeighted)
oil.data<-data.frame(time=oil.wheat.data[,2]+month.addendum,oil=oil.wheat.data[,3])
usa.wheat.data<-data.frame(time=month.ts,wheat=price.ts)
#forylim<-c(smoothed_mean1$y,smoothed_mean2$y,smoothed_mean3$y)
#a<-ggplot(data=toplot)+theme_bw()+coord_cartesian(xlim=c(1,2550),ylim=c(min(forylim)*0.99,max(forylim)*1.01))+labs(y="n. defualts")+theme(panel.border = element_rect(color="black",size=1),panel.grid.major=element_line(colour="black",linetype="dashed"))
a<-ggplot(data=toplot)+theme_bw()+coord_cartesian(xlim=c(1993,2013),ylim=c(0,450))+labs(y="price US \\$")+theme(panel.border = element_rect(color="black",size=1),panel.grid.major=element_line(colour="black",linetype="dotted"))
a<-a+geom_line(aes(x=time,y=wpw),col="red")
a<-a+geom_text(aes(x=time,y=wpw), label="$\\clubsuit$",size=3,colour="red", data=subset(toplot, (toplot$time+0.5) %% 5 == 1))
a<-a+geom_line(data=oil.data,aes(x=time,y=oil),col="blue")
a<-a+geom_text(aes(x=time,y=oil), label="$\\spadesuit$",size=3,colour="blue", data=subset(oil.data, seq(36,36+length(oil.data$time)) %% 60 ==1 ))
a<-a+geom_line(data=usa.wheat.data,aes(x=time,y=wheat),col="green4")
a<-a+geom_text(aes(x=time,y=wheat), label="$\\bullet$",size=5,colour="green4", data=subset(usa.wheat.data, seq(44,44+length(oil.data$time)) %% 60 ==1 ))
#create white area for legenda
a<-a+annotate("rect",xmin=1992,xmax=2006,ymin=340,ymax=470,fill="white")
#legenda
a<-a+annotate("text",x=1993,y=450,label="$\\bullet$",colour="green4",size=5,hjust=0)+annotate("text",x=1994,y=450,label="wheat \\tiny{USA, monthly, metric ton}",colour="green4",size=4,hjust=0)
a<-a+annotate("text",x=1993,y=410,label="$\\clubsuit$",colour="red",size=3,hjust=0)+annotate("text",x=1994,y=410,label="wheat \\tiny{average, annual, metric ton}",colour="red",size=4,hjust=0)
a<-a+annotate("text",x=1993,y=370,label="$\\spadesuit$",colour="blue",size=3,hjust=0)+annotate("text",x=1994,y=370,label="crude oil \\tiny{average, monthly, barrel}",colour="blue",size=4,hjust=0)

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

#figFileNames<-readLines("figFileNames.txt")
#thisFig<-3
#fileName<-figFileNames[thisFig]
fileName<-"fig_observed_prices.tex"
toFileFlag<-T
if(toFileFlag){
tikz(fileName,width=4,height=3,standAlone=T)
}
plot(a)
if(toFileFlag){
dev.off()
system(paste("pdflatex",fileName));
}



