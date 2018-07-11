edges.data<-read.csv("wheat_gephi_edges_annual.csv")
linked<-levels(factor(c(levels(edges.data$Source),levels(edges.data$Target))))
fileName<-"exportMap2.html"
color<-"#CC0000"
weight.multiplier<-10
	write("// start defining maps",fileName)

all.edges<-character()
for(iso in linked){
	write(paste("var",iso,"= {"),fileName,append=T)
	write(paste("id: \"",iso,"\",",sep=""),fileName,append=T)
	if(length(which(iso3.both==iso)<1)){
	write(paste("color: \"",color,"\",",sep=""),fileName,append=T)
	write("svgPath: targetSVG,",fileName,append=T)
}else{
	write(paste("color: \"",color,"\",",sep=""),fileName,append=T)
	write("svgPath: targetSVG2,",fileName,append=T)
}
	write(paste("title: \"",buyers.data$Country[which(buyers.data$ISO3.Code==iso)],"\",",sep=""),fileName,append=T)
	write(paste("latitude: ",buyers.data$LAT[which(buyers.data$ISO3.Code==iso)],",",sep=""),fileName,append=T)
	write(paste("longitude: ",buyers.data$LON[which(buyers.data$ISO3.Code==iso)],",",sep=""),fileName,append=T)
	write("scale: 1.0,",fileName,append=T)
	write("lines: [",fileName,append=T)

	this.latitude<-buyers.data$LAT[which(buyers.data$ISO3.Code==iso)]
	this.longitude<-buyers.data$LON[which(buyers.data$ISO3.Code==iso)]
	this.country.in.edges<-edges.data[which(edges.data$Target==iso),]
	if(dim(this.country.in.edges)[1]>0){
		for(i in 1:nrow(this.country.in.edges)){
			from.latitude<-buyers.data$LAT[which(buyers.data$ISO3.Code==as.character(this.country.in.edges$Source[i]))]
			from.longitude<-buyers.data$LON[which(buyers.data$ISO3.Code==as.character(this.country.in.edges$Source[i]))]
			from.weight<-this.country.in.edges$Weight[i]
			if(this.longitude>from.longitude){
			write(paste("{latitudes: [",this.latitude,",",from.latitude,"],longitudes: [",this.longitude,",",from.longitude,"],arc: -0.8, thickness: ",ceiling(from.weight*weight.multiplier),"},",sep=""),fileName,append=T)
			all.edges[length(all.edges)+1]<-paste("{latitudes: [",this.latitude,",",from.latitude,"],longitudes: [",this.longitude,",",from.longitude,"],arc: -0.8, thickness: ",ceiling(from.weight*weight.multiplier),"},",sep="")
			}
			else{
			write(paste("{latitudes: [",this.latitude,",",from.latitude,"],longitudes: [",this.longitude,",",from.longitude,"],arc: 0.8, thickness: ",ceiling(from.weight*weight.multiplier),"},",sep=""),fileName,append=T)
			all.edges[length(all.edges)+1]<-paste("{latitudes: [",this.latitude,",",from.latitude,"],longitudes: [",this.longitude,",",from.longitude,"],arc: 0.8, thickness: ",ceiling(from.weight*weight.multiplier),"},",sep="")
			}
		}
	}
	this.country.out.edges<-edges.data[which(edges.data$Source==iso),]
	if(dim(this.country.out.edges)[1]>0){
		for(i in 1:nrow(this.country.out.edges)){
			to.latitude<-buyers.data$LAT[which(buyers.data$ISO3.Code==as.character(this.country.out.edges$Target[i]))]
			to.longitude<-buyers.data$LON[which(buyers.data$ISO3.Code==as.character(this.country.out.edges$Target[i]))]
			to.weight<-this.country.out.edges$Weight[i]
			if(this.longitude>to.longitude){
			write(paste("{latitudes: [",this.latitude,",",to.latitude,"],longitudes: [",this.longitude,",",to.longitude,"],arc: 0.8, thickness: ",ceiling(to.weight*weight.multiplier),"},",sep=""),fileName,append=T)
			all.edges[length(all.edges)+1]<-paste("{latitudes: [",this.latitude,",",to.latitude,"],longitudes: [",this.longitude,",",to.longitude,"],arc: 0.8, thickness: ",ceiling(to.weight*weight.multiplier),"},",sep="")
			}
			else{
			write(paste("{latitudes: [",this.latitude,",",to.latitude,"],longitudes: [",this.longitude,",",to.longitude,"],arc: -0.8, thickness: ",ceiling(to.weight*weight.multiplier),"},",sep=""),fileName,append=T)
			all.edges[length(all.edges)+1]<-paste("{latitudes: [",this.latitude,",",to.latitude,"],longitudes: [",this.longitude,",",to.longitude,"],arc: -0.8, thickness: ",ceiling(to.weight*weight.multiplier),"},",sep="")
			}

		}
	}



	write("],",fileName,append=T)
	write("images: [",fileName,append=T)
	write(paste("{label: \"Commercial Relationships ",years.considered[period]," (",buyers.data$Country[which(buyers.data$ISO3.Code==iso)],")\",left: 50,top: 40,color: \"",color,"\",","labelColor: \"",color,"\",","labelRollOverColor: \"",color,"\",labelFontSize: 16},",sep=""),fileName,append=T)
	write(paste("{label: \"show all\",left: 50,top: 60,color: \"",color,"\",","labelColor: \"",color,"\",","labelRollOverColor: \"",color,"\",labelFontSize: 11,linkToObject: \"all\"},",sep=""),fileName,append=T)
	write("]",fileName,append=T)
	
	write("};",fileName,append=T)
}
	write(paste("var all= {"),fileName,append=T)
	write("id: \"all\",",fileName,append=T)
	write("title: \"All\",",fileName,append=T)
	write("lines: [",fileName,append=T)
	write(all.edges,fileName,append=T)
	write("],",fileName,append=T)
	write("images: [",fileName,append=T)
	write(paste("{label: \"Commercial Relationships ",years.considered[period]," (all)\",left: 50,top: 40,color: \"",color,"\",","labelColor: \"",color,"\",","labelRollOverColor: \"",color,"\",labelFontSize: 16},",sep=""),fileName,append=T)
	write(paste("{label: \"Click on a country to show its commercial relationships\",left: 50,top: 60,color: \"",color,"\",","labelColor: \"",color,"\",","labelRollOverColor: \"",color,"\",labelFontSize: 11},",sep=""),fileName,append=T)
	write("]",fileName,append=T)
	
	write("};",fileName,append=T)

write(paste("var countries = [all,",paste(linked,collapse=","),"];",sep=""),fileName,append=T)
html.fileName<-paste("year_",years.considered[period],".html",sep="")
system(paste("cat exportMap1.html exportMap2.html exportMap3.html > ",html.fileName,sep=""))
system(paste("mv ",html.fileName," html/",sep=""))
