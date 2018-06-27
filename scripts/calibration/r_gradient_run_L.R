

###############
###############



for(ite in 1:5){
	food<-data.food[,5:ncol(data.food)]
	feed<-data.feed[,5:ncol(data.feed)]
	seed<-data.seed[,5:ncol(data.seed)]
	pwo<-data.pwo[,5:ncol(data.pwo)]

	demand.multipliers<-read.csv("demandMultipliers.csv",header=F)$V1
	print(demand.multipliers)
	for(i in 1:ncol(demand)){
		food[,i]<-round(food[,i]*demand.multipliers[i])
		feed[,i]<-round(feed[,i]*demand.multipliers[i])
		seed[,i]<-round(seed[,i]*demand.multipliers[i])
		pwo[,i]<-round(pwo[,i]*demand.multipliers[i])
	}

	demand<-food+feed+seed+pwo

	#plot(aggr.production,type="o")
	#lines(colSums(demand),col=2)



	excess.supply<-production-demand
	maximums.excess<-apply(excess.supply,1,max)




	production.to.remove<-numeric()

	for(i in 1:nrow(production)){
		if(maximums.excess[i]>0){
			production.to.remove<-rbind(production.to.remove,numeric(length=ncol(production)))
		}else{
			production.to.remove<-rbind(production.to.remove,as.numeric(production[i,]))
		}
	}


	#misc<-pwo-sv-production.to.remove
	misc<-pwo-production.to.remove


	#write new files
	options(scipen=999)
	first.str<-"Country,ISO3.Code,LAT,LON,markets,commodities,GatherMonthMajor,ProdPlusStockVariation.1991,ProdPlusStockVariation.1992,ProdPlusStockVariation.1993,ProdPlusStockVariation.1994,ProdPlusStockVariation.1995,ProdPlusStockVariation.1996,ProdPlusStockVariation.1997,ProdPlusStockVariation.1998,ProdPlusStockVariation.1999,ProdPlusStockVariation.2000,ProdPlusStockVariation.2001,ProdPlusStockVariation.2002,ProdPlusStockVariation.2003,ProdPlusStockVariation.2004,ProdPlusStockVariation.2005,ProdPlusStockVariation.2006,ProdPlusStockVariation.2007,ProdPlusStockVariation.2008,ProdPlusStockVariation.2009,ProdPlusStockVariation.2010,ProdPlusStockVariation.2011,ProdPlusStockVariation.2012,ProdPlusStockVariation.2013"
	write(first.str,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/producers.csv")
	write(file.buyers[1],"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers.csv")
	write(file.food[1],"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Food.csv")
	write(file.feed[1],"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Feed.csv")
	write(file.seed[1],"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Seed.csv")
	first.str<-"Country,ISO3.Code,LAT,LON,Value.Misc.1992,Value.Misc.1993,Value.Misc.1994,Value.Misc.1995,Value.Misc.1996,Value.Misc.1997,Value.Misc.1998,Value.Misc.1999,Value.Misc.2000,Value.Misc.2001,Value.Misc.2002,Value.Misc.2003,Value.Misc.2004,Value.Misc.2005,Value.Misc.2006,Value.Misc.2007,Value.Misc.2008,Value.Misc.2009,Value.Misc.2010,Value.Misc.2011,Value.Misc.2012,Value.Misc.2013"
	write(first.str,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Misc.csv")
	for(i in 1:nrow(production)){
		if(maximums.excess[i]>0){
			str.p1<-paste(data.producers[i,1],data.producers[i,2],data.producers[i,3],data.producers[i,4],data.producers[i,5],data.producers[i,6],data.producers[i,7],production_start[i]+sv_start[i],sep=",")
			#		str.p2<-paste(production_shifted[i,],collapse=",")
			str.p2<-paste(production[i,],collapse=",")
			str.joined<-paste(str.p1,str.p2,sep=",")
			write(str.joined,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/producers.csv",append=T)

			write(file.buyers[i+1],"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers.csv",append=T)

			str.p1<-paste(data.food[i,1],data.food[i,2],data.food[i,3],data.food[i,4],sep=",")
			str.p2<-paste(food[i,],collapse=",")
			str.joined<-paste(str.p1,str.p2,sep=",")
			write(str.joined,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Food.csv",append=T)
			#		write(file.food[i+1],"/Users/giulioni/Documents/workspace_cms/cms_wheat/data/buyers_Food.csv",append=T)

			str.p1<-paste(data.feed[i,1],data.feed[i,2],data.feed[i,3],data.feed[i,4],sep=",")
			str.p2<-paste(feed[i,],collapse=",")
			str.joined<-paste(str.p1,str.p2,sep=",")
			write(str.joined,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Feed.csv",append=T)	
			#		write(file.feed[i+1],"../../data/buyers_Feed.csv",append=T)

			str.p1<-paste(data.seed[i,1],data.seed[i,2],data.seed[i,3],data.seed[i,4],sep=",")
			str.p2<-paste(seed[i,],collapse=",")
			str.joined<-paste(str.p1,str.p2,sep=",")
			write(str.joined,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Seed.csv",append=T)	
			#		write(file.seed[i+1],"../../data/buyers_Seed.csv",append=T)

			str.p1<-paste(data.pwo[i,1],data.pwo[i,2],data.pwo[i,3],data.pwo[i,4],sep=",")
			str.p2<-paste(misc[i,],collapse=",")
			str.joined<-paste(str.p1,str.p2,sep=",")
			write(str.joined,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Misc.csv",append=T)
		}
	}
	for(i in 1:nrow(production)){
		if(maximums.excess[i]<=0){
			write(file.buyers[i+1],"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers.csv",append=T)

			str.p1<-paste(data.food[i,1],data.food[i,2],data.food[i,3],data.food[i,4],sep=",")
			str.p2<-paste(food[i,],collapse=",")
			str.joined<-paste(str.p1,str.p2,sep=",")
			write(str.joined,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Food.csv",append=T)
			#		write(file.food[i+1],"../../data/buyers_Food.csv",append=T)

			str.p1<-paste(data.feed[i,1],data.feed[i,2],data.feed[i,3],data.feed[i,4],sep=",")
			str.p2<-paste(feed[i,],collapse=",")
			str.joined<-paste(str.p1,str.p2,sep=",")
			write(str.joined,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Feed.csv",append=T)	
			#		write(file.feed[i+1],"../../data/buyers_Feed.csv",append=T)

			str.p1<-paste(data.seed[i,1],data.seed[i,2],data.seed[i,3],data.seed[i,4],sep=",")
			str.p2<-paste(seed[i,],collapse=",")
			str.joined<-paste(str.p1,str.p2,sep=",")
			write(str.joined,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Seed.csv",append=T)	
			#		write(file.seed[i+1],"../../data/buyers_Seed.csv",append=T)


			str.p1<-paste(data.pwo[i,1],data.pwo[i,2],data.pwo[i,3],data.pwo[i,4],sep=",")
			str.p2<-paste(misc[i,],collapse=",")
			str.joined<-paste(str.p1,str.p2,sep=",")
			write(str.joined,"/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Misc.csv",append=T)

		}
	}
	write("","/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/producers.csv",append=T)
	write("","/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers.csv",append=T)
	write("","/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Feed.csv",append=T)
	write("","/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Food.csv",append=T)
	write("","/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Seed.csv",append=T)
	write("","/home/ggiulioni/Documents/workspace_cms/cms_wheat/data/buyers_Misc.csv",append=T)

	system("rm output/z*")
	system("./run_batch")

	source("r_gradient_move_multipliers_L.R")



}
