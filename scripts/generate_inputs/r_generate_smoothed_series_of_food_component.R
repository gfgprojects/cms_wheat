####################################################################################
#  Generate "buyersC_FoodSmoothed.csv" with Smoothing of Food instead of Population
####################################################################################
# 1) read "data/buyersC.csv"
# 2) read "data/buyersC_Food.csv"
# 3) generate "data/buyersC_FoodSmoothed.csv" 
#           SELECT OPTION a) or b)
#   3a) by applying a smoothing method with GCV criterion to select bandwidth
#   3b) by substituting the first value of the smoothed series at 3a) with the real value
# 4) select subCountries for specific smoothing control
#
# Eastern Africa           Middle Africa            Northern Africa         
# Southern Africa          Western Africa           Northern America        
# Central America          Caribbean                South America           
# Central Asia             Eastern Asia             Southern Asia           
# South-Eastern Asia       Western Asia             Eastern Europe          
# Northern Europe          Southern Europe          Western Europe          
# Oceania                  Russian Federation       India                   
# Pakistan                 United States of America China                   
#
# 5) generate plots for checks
####################################################################################

#------------------------------------
# SET OPTIONS:
PrimoDatoReal="YES"   #"NO"   # YES corresponds to option 3b)
parametro=1.00

#-----------------------------------
#select smoothing method
lowess.method<-T     #T for lowess; F for splines

#
Area<-c("Southern Africa")   # c() for none; declare exact name from names above
if(lowess.method){
nknot.Area<-c()     #declare for each item in Area the correspondent smooth.spline() parameter or ::None:: if you want to use lowess
f.Area<-c(0.37)     #declare for each item in Area the correspondent lowess() parameter or ::None:: if you want to use smooth.splines
}else{
nknot.Area<-c(6)
f.Area<-c()    
}

opt<-"SMOOTH"  ## select "SMOOTH" or "POP" for different input of ABM model
#opt<-"POP"  ## select "SMOOTH" or "POP" for different input of ABM model

#flag to generate jpg files
flag.plot<-T

#------------------------------------

# Load Libraries
library(dplyr)

# set directories:
dirOutput<-"/data"


#-------  Set Option for exclude scientific format (e+) in printing ------------
options(scipen=999)    #default is "options(scipen=0)"
#-------------------------------------------------------------------------------

buyers000<-read.csv(paste(getwd(),dirOutput,"/buyersC.csv",sep=""))

FoodC.wide<-read.csv(paste(getwd(),dirOutput,"/buyersC_Food.csv",sep=""))

# smooth of FoodC
# f=0.25
# ho messo f=0.37 perché per valori più bassi l'africa del sud viene inserita tra i produttori, ma con valori piccoli
if(lowess.method){ 
FoodC.wide.smooth0<-apply(data.matrix(FoodC.wide[,-(1:4)]),1,lowess,f=0.5)
# FoodC.wide.smooth0<-apply(data.matrix(FoodC.wide[,-(1:4)]),1,lowess,f=0.25)
}else{
# Smoothing
# cv=FALSE apply for GCV criterion, cv=TRUE for Leave1Out---GCV better whe duplicated points are present::
FoodC.wide.smooth0<-apply(data.matrix(FoodC.wide[,-(1:4)]),1,smooth.spline,cv=FALSE,all.knots=F,nknot=10)#,df.offset=100)#,penalty=0.5)
}

FoodC.wide.smooth<-data.frame(buyers000[,1:4],t(data.frame(sapply(FoodC.wide.smooth0, "[", "y",simplify = T))))
names(FoodC.wide.smooth)<-c(names(buyers000[1:4]),names(FoodC.wide)[-(1:4)])


# subset specific area for defining different threshold::
#---------------------------------------------------------
if(is.null(Area)==FALSE){
  for(i in 1:length(Area)){
    Area.Food<-filter(FoodC.wide,Country==Area[i])
    # use smooth.splines() or lowess()
    if(is.null(nknot.Area[i])==FALSE){
      Area.Smooth0<-apply(data.matrix(Area.Food[,-(1:4)]),1,smooth.spline,cv=FALSE,all.knots=F,nknot=nknot.Area[i])#,df.offset=100)#,penalty=0.5)
      Area.Smooth<-predict(Area.Smooth0[[1]])$y  
    }else{
      Area.Smooth0<-apply(data.matrix(Area.Food[,-(1:4)]),1,lowess,f=f.Area[i])
      Area.Smooth<-Area.Smooth0[[1]]$y  
    }
    
    FoodC.wide.smooth[which(FoodC.wide.smooth$Country==Area[i]),5:ncol(FoodC.wide.smooth)]<-Area.Smooth
  }
}

#---------------------------------------------------------


# Substitute First Value:
#---------------------------------------------------------
if(PrimoDatoReal=="YES") {
  DatoVero=FoodC.wide[,5]
  PrimoDato = parametro * DatoVero
  FoodC.wide.smooth[,5]<-PrimoDato
  }
#---------------------------------------------------------


# Write file:
write.csv(FoodC.wide.smooth,file = paste(getwd(),dirOutput,"/buyersC_FoodSmoothed.csv",sep=""),row.names = F, quote = F)
cat("\n", file = paste(getwd(),dirOutput,"/buyersC_FoodSmoothed.csv",sep=""), append = TRUE)

####-------------- reset scientific format to default ------------
options(scipen=0)
#-----------------------------------------------------------------


# Source for plots:
if(flag.plot){
	source("r_plot_food_component.R")
}
