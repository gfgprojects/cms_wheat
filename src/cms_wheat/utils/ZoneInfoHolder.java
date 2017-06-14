package cms_wheat.utils;

//import cms_wheat.Cms_builder;

//import java.math.BigDecimal;
//import java.math.RoundingMode;

public class ZoneInfoHolder{
	double production=0;
	double consumption;
	double excessSupply,excessDemand,shareOfExcessSupply;
	String name;

	public ZoneInfoHolder(){
	}

	public void setConsumption(double thisZoneConsumption){
		consumption=thisZoneConsumption;
//		System.out.println(name+" consumption "+consumption);
	}
	public void setProduction(double thisZoneProduction){
		production=thisZoneProduction;
//		System.out.println(name+" production "+production);
	}
	public void setExcessSupplyAndDemand(){
		excessSupply=Math.max(0,production-consumption);
		excessDemand=Math.max(0,consumption-production);
//		System.out.println(name+" excess supply "+excessSupply+" excess demand "+excessDemand);		
	}
	public void setShareOfExcessSupply(double totalExcessSupply){
		shareOfExcessSupply=excessSupply/totalExcessSupply;
	}
	public double getShareOfExcessSupply(){
		return shareOfExcessSupply;
	}
	public void setName(String thisZoneName){
		name=thisZoneName;
	}
	public String getName(){
		return name;
	}
	public double getExcessSupply(){
		return excessSupply;
	}
	public double getExcessDemand(){
		return excessDemand;
	}
	public double getConsumption(){
		return consumption;
	}
	public double getProduction(){
		return production;
	}
	
}
