#carica i dati reali da utilizzati nella funzione da minimizzare


#####read non weighted and weighted world average price computed by Edmondo
y.prices<-read.csv("e_world_yearly_prices.csv")
weighted.world.yearly.prices.real<-y.prices$WorldPriceWeighted
#normalized.weighted.world.yearly.prices.real<-weighted.world.yearly.prices.real/weighted.world.yearly.prices.real[1]
normalized.weighted.world.yearly.prices.real<-weighted.world.yearly.prices.real/min(weighted.world.yearly.prices.real)


