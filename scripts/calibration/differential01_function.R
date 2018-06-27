
#parametri<-c(0.08,0.07,53,15,15,0.9,0.3,0.8,3,8,0.3)
#valutazione(parametri)

valutazione<-function(parameters){
#========= scrive il file batch_params.xml


write("<?xml version=\"1.0\" ?>","batch_params.xml")
write("<sweep runs=\"1\">","batch_params.xml",append=T)
write(paste("<parameter name=\"shareOfDemandToBeMoved\" type=\"constant\" constant_type=\"double\" value=\"",parameters[1],"\"></parameter>",sep=""),"batch_params.xml",append=T)
write(paste("<parameter name=\"percentageOfPriceMarkDownInNewlyAccessibleMarkets\" type=\"constant\" constant_type=\"double\" value=\"",parameters[2],"\"></parameter>",sep=""),"batch_params.xml",append=T)
write(paste("<parameter name=\"transportCostsTuner\" type=\"constant\" constant_type=\"double\" value=\"",parameters[3],"\"></parameter>",sep=""),"batch_params.xml",append=T)
write(paste("<parameter name=\"demandFunctionInterceptTuner\" type=\"constant\" constant_type=\"double\" value=\"",parameters[4],"\"></parameter>",sep=""),"batch_params.xml",append=T)
write(paste("<parameter name=\"demandFunctionSlopeTuner\" type=\"constant\" constant_type=\"double\" value=\"",parameters[5],"\"></parameter>",sep=""),"batch_params.xml",append=T)
write("</sweep>","batch_params.xml",append=T)


#=========== copia file dei parametri

system("mv batch_params.xml /Users/giulioni/Documents/workspace_cms/cms_wheat/batch/")

#=========== cancella file

system("rm output/z*")

#=========== lancia la simulazione

system("./run_batch")


#=========== funzione da minimizzare
#carica i dati e valuta la distanza tra le due distribuzioni

if(F){
#####compute non weighted and weighted world average price from simulation sim_output

data.sessions<-read.csv("output/z_sessions.csv")
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

sessions.prices<-sessions.prices[199:(198+nrow(y.prices)*12),]
sessions.quantities<-sessions.quantities[199:(198+nrow(y.prices)*12),]
sessions.offered.quantities<-sessions.offered.quantities[199:(198+nrow(y.prices)*12),]

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

#plot(normalized.weighted.world.yearly.prices.real,type="l")
#lines(normalized.weighted.world.yearly.prices.sim,col=2)

sum((normalized.weighted.world.yearly.prices.real-normalized.weighted.world.yearly.prices.sim)^2)
}
runif(1)
}
