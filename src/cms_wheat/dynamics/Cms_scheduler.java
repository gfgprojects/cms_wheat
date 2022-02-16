package cms_wheat.dynamics;
import java.util.ArrayList;
import java.util.Iterator;

import cms_wheat.Cms_builder;
import cms_wheat.agents.Producer;
import cms_wheat.agents.Buyer;
import cms_wheat.utils.ZoneInfoHolder;

import repast.simphony.context.Context;
import repast.simphony.util.collections.IndexedIterable;
import repast.simphony.engine.schedule.ScheduleParameters;
import repast.simphony.essentials.RepastEssentials;
import repast.simphony.engine.schedule.DefaultActionFactory;
import repast.simphony.engine.schedule.IAction;
/**
 * The class schedules the events of the main loop.
 * @author giulioni
 *
 */
public class Cms_scheduler{
	public IndexedIterable<Object> buyersList,producersList,marketsList;
	public Context<Object> cmsContext;
	public ArrayList<Double> crudeOilPrices;
	ArrayList<ZoneInfoHolder> zonesList=new ArrayList<ZoneInfoHolder>();
	Iterator<Double> crudeOilPricesIterator;
	public static double crudeOilPrice;
	ScheduleParameters scheduleParameters;
	DefaultActionFactory statActionFactory;
	IAction statAction;
	Producer aProducer;
	Buyer aBuyer;
	ZoneInfoHolder aZoneInfoHolder;
	double totalExcessSupply;

//	public int productionFreq=10;

	public Cms_scheduler(Context<Object> theContext,ArrayList<Double> crudeOil){
		cmsContext=theContext;
		crudeOilPrices=crudeOil;
		crudeOilPricesIterator=crudeOilPrices.iterator();
		crudeOilPrice=crudeOilPricesIterator.next();
		crudeOilPricesIterator.remove();

		try{
			buyersList=cmsContext.getObjects(Class.forName("cms_wheat.agents.Buyer"));
			producersList=cmsContext.getObjects(Class.forName("cms_wheat.agents.Producer"));
			marketsList=cmsContext.getObjects(Class.forName("cms_wheat.agents.Market"));
		}
		catch(ClassNotFoundException e){
			System.out.println("Class not found");
		}
		//create the zonesList and fill each zone with data on excess demand and supply to be used by buyers when setting demand intercept 
		for(int i=0;i<buyersList.size();i++){
			aBuyer=(Buyer)buyersList.get(i);
			aZoneInfoHolder=new ZoneInfoHolder();
			aZoneInfoHolder.setName(aBuyer.getName());
			aZoneInfoHolder.setConsumption(aBuyer.getAverageConsumption());
			zonesList.add(aZoneInfoHolder);
		}
		for(int i=0;i<producersList.size();i++){
			aProducer=(Producer)producersList.get(i);
			for(int j=0;j<zonesList.size();j++){
				aZoneInfoHolder=zonesList.get(j);
				if(aProducer.getName().equals(aZoneInfoHolder.getName())){
					aZoneInfoHolder.setProduction(aProducer.getProduction()/Cms_builder.productionCycleLength);
				}				
			}
		}
		for(int j=0;j<zonesList.size();j++){
			aZoneInfoHolder=zonesList.get(j);
			aZoneInfoHolder.setExcessSupplyAndDemand();
		}
		totalExcessSupply=0;
		for(int j=0;j<zonesList.size();j++){
			aZoneInfoHolder=zonesList.get(j);
			totalExcessSupply+=aZoneInfoHolder.getExcessSupply();
		}
		for(int j=0;j<zonesList.size();j++){
			aZoneInfoHolder=zonesList.get(j);
			aZoneInfoHolder.setShareOfExcessSupply(totalExcessSupply);;
		}
		for(int i=0;i<buyersList.size();i++){
			aBuyer=(Buyer)buyersList.get(i);
			aBuyer.setZoneInfoHolder(zonesList);
		}

		//create Action Factory to use when scheduling
		statActionFactory = new DefaultActionFactory();

	}
	
	/**
	 * this method calls all the other schedule method of this class.
	 */

	public void scheduleEvents(){

		if(Cms_builder.verboseFlag){
			scheduleParameters=ScheduleParameters.createRepeating(1,1,100.0);
			Cms_builder.schedule.schedule(scheduleParameters,this,"schedulePrintStartSimulationTimeStep");
			scheduleParameters=ScheduleParameters.createRepeating(1,1,0.0);
			Cms_builder.schedule.schedule(scheduleParameters,this,"schedulePrintEndSimulationTimeStep");
		}

		scheduleParameters=ScheduleParameters.createOneTime(Cms_builder.startUsingInputsFromTimeTick,101);
//		scheduleParameters=ScheduleParameters.createOneTime(1,101);
		Cms_builder.schedule.schedule(scheduleParameters,this,"scheduleStartDemandShift");
/*
		scheduleParameters=ScheduleParameters.createRepeating(1,40,101);
		Cms_builder.schedule.schedule(scheduleParameters,this,"scheduleVerboseFlagTrue");
		scheduleParameters=ScheduleParameters.createRepeating(1,40,0);
		Cms_builder.schedule.schedule(scheduleParameters,this,"scheduleVerboseFlagFalse");
*/
		scheduleParameters=ScheduleParameters.createRepeating(1,Cms_builder.importPolicyDecisionInterval,41.0);
		Cms_builder.schedule.schedule(scheduleParameters,this,"scheduleStepBuyersImportPolicy");

		scheduleParameters=ScheduleParameters.createRepeating(1,Cms_builder.exportPolicyDecisionInterval,40.0);
		Cms_builder.schedule.schedule(scheduleParameters,this,"scheduleStepProducersExportPolicy");

		scheduleParameters=ScheduleParameters.createRepeating(1,1,39.0);
		Cms_builder.schedule.schedule(scheduleParameters,this,"scheduleUnpdateCrudeOilPrice");

		scheduleParameters=ScheduleParameters.createRepeating(1,1,38.0);
//		scheduleParameters=ScheduleParameters.createOneTime(1,38.0);
		Cms_builder.schedule.schedule(scheduleParameters,this,"scheduleBuyersStepBuyingStrategy");

		scheduleParameters=ScheduleParameters.createRepeating(1,1,37.0);
		Cms_builder.schedule.schedule(scheduleParameters,this,"scheduleMarketsPerformSessions");

		scheduleParameters=ScheduleParameters.createRepeating(1,1,36.0);
		Cms_builder.schedule.schedule(scheduleParameters,this,"scheduleBuyersAccountConsumption");

		scheduleParameters=ScheduleParameters.createRepeating(1,1,34.0);
		Cms_builder.schedule.schedule(scheduleParameters,this,"schedulePrintProductionIfVerbouse");
		for(int i=0;i<producersList.size();i++){
			aProducer=(Producer)producersList.get(i);
			int tfp=aProducer.getTimeOfFirstProduction();
			if(tfp>0){
				scheduleParameters=ScheduleParameters.createRepeating(tfp,Cms_builder.productionCycleLength,32.0);
				Cms_builder.schedule.schedule(scheduleParameters,aProducer,"makeProduction");
			}
			int tfpSpring=aProducer.getTimeOfFirstProductionSpring();
			if(tfpSpring>0){
				scheduleParameters=ScheduleParameters.createRepeating(tfpSpring,Cms_builder.productionCycleLength,32.0);
				Cms_builder.schedule.schedule(scheduleParameters,aProducer,"makeProductionSpring");
			}
			if(tfp>0 && tfpSpring>0){
				if(aProducer.getProductionWinter()>=aProducer.getProductionSpring()){
					scheduleParameters=ScheduleParameters.createRepeating(tfp,Cms_builder.productionCycleLength,33.0);
					Cms_builder.schedule.schedule(scheduleParameters,aProducer,"manageStockBeforeWinterProduction");
				}
				else{
					scheduleParameters=ScheduleParameters.createRepeating(tfpSpring,Cms_builder.productionCycleLength,33.0);
					Cms_builder.schedule.schedule(scheduleParameters,aProducer,"manageStockBeforeSpringProduction");
				}
			}
			else{
				if(tfp>0){
					scheduleParameters=ScheduleParameters.createRepeating(tfp,Cms_builder.productionCycleLength,33.0);
					Cms_builder.schedule.schedule(scheduleParameters,aProducer,"manageStock");
				}
				else{
					scheduleParameters=ScheduleParameters.createRepeating(tfpSpring,Cms_builder.productionCycleLength,33.0);
					Cms_builder.schedule.schedule(scheduleParameters,aProducer,"manageStock");
				}
			
			}

		}
	}

	public void schedulePrintStartSimulationTimeStep(){
		System.out.println();
		System.out.println("===================================================================");
		System.out.println("START SIMULATION TIME STEP: "+RepastEssentials.GetTickCount());
		System.out.println("====================================================================");
		System.out.println();
	}

	public void schedulePrintEndSimulationTimeStep(){
		System.out.println();
		System.out.println("===================================================================");
		System.out.println("END SIMULATION TIME STEP: "+RepastEssentials.GetTickCount());
		System.out.println("====================================================================");
		System.out.println();
	}
	public void scheduleStepBuyersImportPolicy(){
		if(Cms_builder.verboseFlag){
			System.out.println();
			System.out.println("BUYERS: STEP IMPORT POLICY");
		}

		statAction=statActionFactory.createActionForIterable(buyersList,"stepImportAllowedFlag",false);
		statAction.execute();
	}
	public void scheduleStepProducersExportPolicy(){
		if(Cms_builder.verboseFlag){
			System.out.println();
			System.out.println("PRODUCERS: STEP EXPORT POLICY");
		}
		statAction=statActionFactory.createActionForIterable(producersList,"stepExportAllowedFlag",false);
		statAction.execute();
	}
	public void scheduleBuyersStepBuyingStrategy(){
/*  
		if(RepastEssentials.GetTickCount()==288){
			Cms_builder.verboseFlag=true;
			System.out.println("===================================================================");
			System.out.println("START SIMULATION TIME STEP: "+RepastEssentials.GetTickCount());
			System.out.println("====================================================================");
		}
		if(RepastEssentials.GetTickCount()==417){
			Cms_builder.verboseFlag=false;
		}
		*/
		if(Cms_builder.verboseFlag){
			System.out.println();
			System.out.println("BUYERS: STEP BUYING STRATEGY");
		}
		statAction=statActionFactory.createActionForIterable(buyersList,"stepBuyingStrategy",false,producersList);
		statAction.execute();
	}
	public void scheduleUnpdateCrudeOilPrice(){
		if(RepastEssentials.GetTickCount()>Cms_builder.startUsingInputsFromTimeTick && crudeOilPrices.size()>0){
			crudeOilPrice=crudeOilPricesIterator.next();
			crudeOilPricesIterator.remove();
			if(Cms_builder.verboseFlag){System.out.println(RepastEssentials.GetTickCount()+" Global: crude oil price updated: "+crudeOilPrice);}
//			System.out.println("Time "+RepastEssentials.GetTickCount()+" Global: crude oil price updated: "+crudeOilPrice);
		}
	}
	public void scheduleMarketsPerformSessions(){
		if(Cms_builder.verboseFlag){
			System.out.println();
			System.out.println("MARKETS: PERFORM SESSIONS");
		}
		statAction=statActionFactory.createActionForIterable(marketsList,"performMarketSessions",false);
		statAction.execute();
	}
	public void scheduleBuyersAccountConsumption(){
		if(Cms_builder.verboseFlag){
			System.out.println();
			System.out.println("BUYERS: ACCOUNT CONSUMPTION");
		}
		statAction=statActionFactory.createActionForIterable(buyersList,"accountConsumption",false);
		statAction.execute();
	}

	public void schedulePrintProductionIfVerbouse(){
		if(Cms_builder.verboseFlag){
			System.out.println();
			System.out.println("PRODUCERS: MAKE PRODUCTION");
		}
	}
	public void scheduleVerboseFlagTrue(){
		Cms_builder.verboseFlag=true;
			System.out.println("=========time "+RepastEssentials.GetTickCount());

	}
	public void scheduleVerboseFlagFalse(){
		Cms_builder.verboseFlag=false;
	}
	public void scheduleStartDemandShift(){
		Cms_builder.allowDemadsShiftAccordingToGapToTarget=true;
	}

	public double getCrudeOilPrice(){
		return crudeOilPrice;
	}


}
