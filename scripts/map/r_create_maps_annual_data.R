#source("r_origin.R")

#read the parameters file
str1<-system("grep startUsingInputsFromTimeTick= ../../src/cms_wheat/Cms_builder.java",intern=T)
str2<-unlist(strsplit(str1,"="))[2]
str3<-unlist(strsplit(str2,";"))[1]
start.real.data<-as.numeric(str3)
sum.ends<-seq(start.real.data+11,dim(imp.dyn)[3],12)
sum.starts<-sum.ends-11

data.aggregate<-read.csv("../../output/z_aggregate.csv")
data.aggregate<-data.aggregate[,-1]

food<-read.csv("../../data/buyers_Food.csv",)
first.year.of.demand<-as.numeric(unlist(strsplit(names(food)[5],"[.]"))[3])

years.considered<-seq(first.year.of.demand,first.year.of.demand+length(sum.starts)-1)
#from monthly to annual imp.dyn

imp.dyn.annual<-array(0,dim=c(length(buyers),length(buyers),length(sum.starts)),dimnames=list(buyers,buyers,years.considered))
for(yearid in 1:length(sum.starts)){
#for(yearid in 1:1){
	    tmp.imp.dyn<-imp.dyn[,,sum.starts[yearid]:sum.ends[yearid]]
		for(buyid in 1:length(buyers)){
			for(selid in 1:length(buyers)){
				value<-round(sum(tmp.imp.dyn[buyid,selid,])/12)
				if(value>0*10^6){
				imp.dyn.annual[buyid,selid,yearid]<-value
			}
			}
		}
		
}

countries.names<-dimnames(imp.dyn)[[1]]
#isocodes
buyers.data<-read.csv("../../data/buyers.csv")
producers.data<-read.csv("../../data/producers.csv")
for(i in 1:nrow(producers.data)){
	buyers.data$LAT[i]<-(buyers.data$LAT[i]+producers.data$LAT[i])/2
	buyers.data$LON[i]<-(buyers.data$LON[i]+producers.data$LON[i])/2

}
iso3.both<-as.character(buyers.data$ISO3.Code[1:nrow(producers.data)])
iso3<-as.character(buyers.data$ISO3.Code[order(buyers.data$Country)])

for(period in 1:length(years.considered)){
	source("r_write_import_network_for_gephi_annual.R")
	source("r_makeExportMap2_annual.R")
	source("r_create_html_index_annual.R")
}
source("r_create_html_index_annual.R")


