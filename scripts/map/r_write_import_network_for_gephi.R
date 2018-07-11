#build the imp.dyn array by running the r_origin script
#source("r_origin.R")
countries.names<-dimnames(imp.dyn)[[1]]
#isocodes
buyers.data<-read.csv("../../data/buyers.csv")
iso3<-as.character(buyers.data$ISO3.Code[order(buyers.data$Country)])

period<-415
out_file_name<-"wheat_gephi_edges_2010.csv"
p.matrix<-imp.dyn[,,period]
c.total<-rowSums(p.matrix)
c.national<-diag(p.matrix)
imports<-c.total-c.national
tot.q<-sum(c.total)
w.matrix<-100*p.matrix/tot.q
write("Source,Target,Type,Weight",out_file_name)
for(i in 1:ncol(p.matrix)){
	for(j in 1:ncol(p.matrix)){
		if(p.matrix[i,j]>0){
			if(i==j){
			}else{
			write(paste(iso3[j],iso3[i],"Direct",w.matrix[i,j],sep=","),out_file_name,append=T)
			}
		}
	}
}
