library("DEoptim")

#system("date |mutt -s 'differential evolution iniziato' g.giulioni@gmail.com,edidigiu@gmail.com")
#system("date |mutt -s 'differential evolution iniziato' g.giulioni@gmail.com")
source("differential01_function.R")
source("differential02_dati.R")

#par1 = shareOfDemandToBeMoved 
#par2 = percentageOfPriceMarkDownInNewlyAccessibleMarkets
#par3 = transportCostsTuner
#par4 = demandFunctionInterceptTuner
#par5 = demandFunctionSlopeTuner

minpar01<-0.01
minpar02<-0.01
minpar03<-0.001
minpar04<-0.1
minpar05<-0.1

maxpar01<-0.2
maxpar02<-0.2
maxpar03<-0.05
maxpar04<-1.5
maxpar05<-1.5

minimi<-c(minpar01,minpar02,minpar03,minpar04,minpar05)

massimi<-c(maxpar01,maxpar02,maxpar03,maxpar04,maxpar05)

soluzione<-DEoptim(valutazione,minimi,massimi,control = DEoptim.control(NP=5,itermax=2))
#NP=5

system("date > stima.txt")
write("estimated parameters","stima.txt",append=T)
#for(i in 1:length(soluzione$optim$bestmem)){
#write(soluzione$optim$bestmem[i],"stima.txt",append=T)
#}
write(soluzione$optim$bestmem[1],"stima.txt",append=T)
write(soluzione$optim$bestmem[2],"stima.txt",append=T)
write(soluzione$optim$bestmem[3],"stima.txt",append=T)
write(soluzione$optim$bestmem[4],"stima.txt",append=T)
write(soluzione$optim$bestmem[5],"stima.txt",append=T)
write("best value","stima.txt",append=T)
write(soluzione$optim$bestval,"stima.txt",append=T)
write("number of iterations","stima.txt",append=T)
write(soluzione$optim$iter,"stima.txt",append=T)
write("number of times the function was evaluated","stima.txt",append=T)
write(soluzione$optim$nfeval,"stima.txt",append=T)
write(soluzione$member$bestmemit,"best.txt")
#valutazione(soluzione$optim$bestmem)
#system("cat stima.txt|mutt -s 'differential evolution terminato' g.giulioni@gmail.com,edidigiu@gmail.com -a batch_parameters.xml -a consumersWealth_run1.txt")
#system("cat stima.txt|mutt -s 'differential evolution terminato' g.giulioni@gmail.com -a batch_parameters.xml -a consumersWealth_run1.txt")
