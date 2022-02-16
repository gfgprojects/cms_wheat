package cms_wheat;

import cms_wheat.agents.Producer;
import cms_wheat.agents.Buyer;
import cms_wheat.agents.Market;
import cms_wheat.utils.MarketLongitudeComparator;
import cms_wheat.dynamics.Cms_scheduler;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Collections;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.charset.Charset;
import java.math.BigDecimal;
import java.math.RoundingMode;

import repast.simphony.context.Context;
import repast.simphony.dataLoader.ContextBuilder;
import repast.simphony.context.space.gis.GeographyFactoryFinder;
import repast.simphony.context.space.gis.GeographyFactory;
import repast.simphony.space.gis.Geography;
import repast.simphony.space.gis.GeographyParameters;
import repast.simphony.engine.environment.RunEnvironment;
import repast.simphony.util.collections.IndexedIterable;
import repast.simphony.engine.schedule.ISchedule;
import repast.simphony.parameter.Parameters;
import repast.simphony.random.RandomHelper;

import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Point;

import org.geotools.referencing.GeodeticCalculator;

public class Cms_builder implements ContextBuilder<Object> {
	public static boolean verboseFlag=false;
	public static boolean autarkyAtTheBeginning=false;

	public static boolean allowDemadsShiftAccordingToGapToTarget=false;
	Producer aProducer;
	Buyer aBuyer;
	Market aMarket;
	Coordinate coord;
	Point geom;
	List<String> lines,lines1,linesBuyersFood,linesBuyersFeed,linesBuyersOtherUses,linesBuyersSeed;
	String tmpVarieties="";
	String tmpMarkets="";
	ArrayList<Market> marketsList;
	IndexedIterable<Object> producersList,buyersList;	
	public ArrayList<Double> bidAndAskPrices;
	public static GeodeticCalculator distanceCalculator;
	public static ISchedule schedule;
	private boolean tmpMustImportFlag;

	
	int batchStoppingTime=2;
	public static int productionCycleLength,exportPolicyDecisionInterval,importPolicyDecisionInterval,globalProduction,minimumImportQuantity,producersPricesMemoryLength,startUsingInputsFromTimeTick;
	public static double consumptionShareToSetMinimumConsumption,consumptionShareToSetMaximumConsumption,productionRateOfChangeControl,probabilityToAllowExport,probabilityToAllowImport,toleranceInMovingDemand,shareOfDemandToBeMoved,percentageOfPriceMarkDownInNewlyAccessibleMarkets,weightOfDistanceInInitializingIntercept,percentageChangeInTargetProduction,priceThresholdToIncreaseTargetProduction,priceThresholdToDecreaseTargetProduction,transportCostsTuner,demandFunctionInterceptTuner,demandFunctionSlopeTuner,demandFunctionReferencePrice;
	public static double shareOfDemandToBeMovedToLowerPrice=0.01;
	public static double exponentOfLogisticInDemandToBeMoved=-2;
//	public static double shareOfDemandToBeMovedFromHigherPrice;

public Context<Object> build(Context<Object> context) {

Parameters params = RunEnvironment.getInstance().getParameters();
	verboseFlag=false;
	autarkyAtTheBeginning=false;
	productionCycleLength=12;
	exportPolicyDecisionInterval=1;
	importPolicyDecisionInterval=12;
	globalProduction=50000000;
	producersPricesMemoryLength=12;
	minimumImportQuantity=100;
	weightOfDistanceInInitializingIntercept=0.0;
	consumptionShareToSetMinimumConsumption=0.75;
	consumptionShareToSetMaximumConsumption=1.25;
	productionRateOfChangeControl=0.0;
	probabilityToAllowExport=1.0;
	probabilityToAllowImport=1.0;
	toleranceInMovingDemand=0.0;
	percentageChangeInTargetProduction=0.0;
	priceThresholdToIncreaseTargetProduction=8.0;
	priceThresholdToDecreaseTargetProduction=2.0;
	startUsingInputsFromTimeTick=24; //192
//	batchStoppingTime=460; //se startUsing=199 allora 600, o 460 in differential evolution
	batchStoppingTime=313; //313  505
	shareOfDemandToBeMoved=(double)params.getValue("shareOfDemandToBeMoved");
	percentageOfPriceMarkDownInNewlyAccessibleMarkets=(double)params.getValue("percentageOfPriceMarkDownInNewlyAccessibleMarkets");
	transportCostsTuner=(double)params.getValue("transportCostsTuner");
	demandFunctionInterceptTuner=(double)params.getValue("demandFunctionInterceptTuner");
	demandFunctionSlopeTuner=(double)params.getValue("demandFunctionSlopeTuner");
	demandFunctionReferencePrice=(double)params.getValue("demandFunctionReferencePrice");
RandomHelper.setSeed(-1866858664);
//shareOfDemandToBeMovedToLowerPrice=shareOfDemandToBeMoved;
//shareOfDemandToBeMovedFromHigherPrice=shareOfDemandToBeMoved;
//	System.out.println("InterceptTuner "+demandFunctionInterceptTuner);
	if(verboseFlag){
		System.out.println();
		System.out.println("===================================================================");
		System.out.println("BEGIN INITIALIZATION");
		System.out.println("====================================================================");
		System.out.println("");
	}

	GeographyParameters<Object> geoParams = new GeographyParameters<Object>();
	GeographyFactory factory = GeographyFactoryFinder.createGeographyFactory(null);
	Geography<Object> geography = factory.createGeography("Geography", context, geoParams);
	GeometryFactory fac = new GeometryFactory();
	

	distanceCalculator=new GeodeticCalculator(geography.getCRS());

	
	
	if(verboseFlag){
		System.out.println("");
	}
	bidAndAskPrices=new ArrayList<Double>();
	for(int i=0;i<3000;i++){
		bidAndAskPrices.add((new BigDecimal(i*0.01)).setScale(2,RoundingMode.HALF_EVEN).doubleValue());
	}


	//Producers creation
	try{
		lines1=Files.readAllLines(Paths.get(System.getProperty("user.dir")+"/data/producers_s.csv"), Charset.forName("UTF-8"));
	} catch (IOException e) {
		e.printStackTrace();
	}

	try{
		lines=Files.readAllLines(Paths.get(System.getProperty("user.dir")+"/data/producers_w.csv"), Charset.forName("UTF-8"));
	} catch (IOException e) {
		e.printStackTrace();
	}
	for(int i=1;i<lines.size()-1;i++){
		String[] parts = ((String)lines.get(i)).split(",");
		String[] parts1 = ((String)lines1.get(i)).split(",");
		ArrayList<Integer> tmpProductionInputs=new ArrayList<Integer>();
		ArrayList<Integer> tmpProductionInputs1=new ArrayList<Integer>();
		for(int j=7;j<parts.length;j++){
			Integer tmpInt=Integer.valueOf(parts[j]);
			int tmpIntegerValue=(int)(tmpInt*1.0);
			tmpProductionInputs.add(Integer.valueOf(tmpIntegerValue));
			tmpInt=Integer.valueOf(parts1[j]);
			tmpIntegerValue=(int)(tmpInt*1.0);
			tmpProductionInputs1.add(Integer.valueOf(tmpIntegerValue));
		}
		aProducer=new Producer(parts[0],parts[1],Double.valueOf(parts[2]),Double.valueOf(parts[3]),parts[4],parts[5],tmpProductionInputs,tmpProductionInputs1,bidAndAskPrices);
		aProducer.setup((Integer.valueOf(parts[6])).intValue(),(Integer.valueOf(parts1[6])).intValue());
		tmpMarkets=tmpMarkets+"|"+parts[4];
		tmpVarieties=tmpVarieties+"|"+parts[5];
		context.add(aProducer);
		coord = new Coordinate(aProducer.getLongitude(),aProducer.getLatitude());
		geom = fac.createPoint(coord);
		geography.move(aProducer, geom);
	}
	if(verboseFlag){
		System.out.println("");
	}
	
	//Buyers creation
	try{
		lines=Files.readAllLines(Paths.get(System.getProperty("user.dir")+"/data/buyers.csv"), Charset.forName("UTF-8"));
		linesBuyersFood=Files.readAllLines(Paths.get(System.getProperty("user.dir")+"/data/buyers_Food.csv"), Charset.forName("UTF-8"));
		linesBuyersFeed=Files.readAllLines(Paths.get(System.getProperty("user.dir")+"/data/buyers_Feed.csv"), Charset.forName("UTF-8"));
		linesBuyersOtherUses=Files.readAllLines(Paths.get(System.getProperty("user.dir")+"/data/buyers_Misc.csv"), Charset.forName("UTF-8"));
		linesBuyersSeed=Files.readAllLines(Paths.get(System.getProperty("user.dir")+"/data/buyers_Seed.csv"), Charset.forName("UTF-8"));
	} catch (IOException e) {
		e.printStackTrace();
	}
//		String[] partsTmp = ((String)lines.get(1)).split(",");
//			System.out.println(partsTmp[4]);
	for(int i=1;i<lines.size()-1;i++){
		String[] parts = ((String)lines.get(i)).split(",");
		String[] partsFood = ((String)linesBuyersFood.get(i)).split(",");
		String[] partsFeed = ((String)linesBuyersFeed.get(i)).split(",");
		String[] partsOtherUses = ((String)linesBuyersOtherUses.get(i)).split(",");
		String[] partsSeed = ((String)linesBuyersSeed.get(i)).split(",");
		ArrayList<Integer> tmpPopulationInputs=new ArrayList<Integer>();
		ArrayList<Integer> tmpFoodInputs=new ArrayList<Integer>();
		ArrayList<Integer> tmpOtherDemandComponentsInputs=new ArrayList<Integer>();
		for(int j=4;j<partsFood.length;j++){
			int tmpPop = (int)((Double.valueOf(parts[j])).doubleValue()*1000);
			tmpPopulationInputs.add(Integer.valueOf(tmpPop));
			int tmpFood=(Double.valueOf(partsFood[j-0])).intValue();
//			tmpFood=(int)(tmpFood/productionCycleLength);
			tmpFoodInputs.add(Integer.valueOf(tmpFood));
			int tmpFeed=Integer.valueOf(partsFeed[j-0]);
			int tmpOtherUses=Integer.valueOf(partsOtherUses[j-0]);
			int tmpSeed=Integer.valueOf(partsSeed[j-0]);
			int tmpOtherDemandComponents=tmpFeed+tmpOtherUses+tmpSeed;
//			tmpOtherDemandComponents=0;
			tmpOtherDemandComponentsInputs.add(Integer.valueOf(tmpOtherDemandComponents));
		}
		//build periodic population time series (ex montly) starting from yearly time series
		ArrayList<Integer> tmpPopulationInputsAdjustedForPeriodicity=new ArrayList<Integer>();
		for(int j=0;j<tmpPopulationInputs.size()-1;j++){
			tmpPopulationInputsAdjustedForPeriodicity.add(tmpPopulationInputs.get(j));
			double popChange=(double)(tmpPopulationInputs.get(j+1)-tmpPopulationInputs.get(j))/productionCycleLength;
			for(int z=1;z<productionCycleLength;z++){
				tmpPopulationInputsAdjustedForPeriodicity.add(tmpPopulationInputs.get(j)+(int)(z*popChange));				
			}
//			System.out.println("j "+j+" popsize "+tmpPopulationInputs.get(j)+" popsize "+tmpPopulationInputsAdjustedForPeriodicity.size());
		}
		tmpPopulationInputsAdjustedForPeriodicity.add(tmpPopulationInputs.get(tmpPopulationInputs.size()-1));
		for(int z=1;z<productionCycleLength;z++){
				tmpPopulationInputsAdjustedForPeriodicity.add(tmpPopulationInputs.get(tmpPopulationInputs.size()-1));				
			}


			//build periodic food time series (ex montly) starting from periodic population
		Double yearlyPerCapitaConsumption=Double.valueOf(parts[4]);
		double periodicPerCapitaConsumption=yearlyPerCapitaConsumption/productionCycleLength;

		ArrayList<Integer> tmpFoodDemandComponentAdjustedForPeriodicity=new ArrayList<Integer>();
		//if food component is computed according to population using data in buyers.csv
		/*
		for(int f=0;f<tmpPopulationInputsAdjustedForPeriodicity.size();f++){
			tmpFoodDemandComponentAdjustedForPeriodicity.add(Integer.valueOf((int)(periodicPerCapitaConsumption*tmpPopulationInputsAdjustedForPeriodicity.get(f))));
		}
		*/
		//if food component is computed according to smoothed FAO data in buyers_Food.csv
/*
		for(int j=0;j<tmpFoodInputs.size()-1;j++){
			tmpFoodDemandComponentAdjustedForPeriodicity.add(tmpFoodInputs.get(j));
			double foodChange=(double)(tmpFoodInputs.get(j+1)-tmpFoodInputs.get(j))/productionCycleLength;
			for(int z=1;z<productionCycleLength;z++){
				tmpFoodDemandComponentAdjustedForPeriodicity.add(tmpFoodInputs.get(j)+(int)(z*foodChange));				
			}
		}
		tmpFoodDemandComponentAdjustedForPeriodicity.add(tmpFoodInputs.get(tmpFoodInputs.size()-1));
*/
		for(int j=0;j<tmpFoodInputs.size();j++){
			int tmpFood=tmpFoodInputs.get(j);
			double tmpFoodAdjustedForPeriodicity=(double)(tmpFood/productionCycleLength);
			for(int z=1;z<productionCycleLength;z++){
				tmpFoodDemandComponentAdjustedForPeriodicity.add((int)(tmpFoodAdjustedForPeriodicity));				
			}
			tmpFoodDemandComponentAdjustedForPeriodicity.add(tmpFood-((int)(tmpFoodAdjustedForPeriodicity*(productionCycleLength-1))));
		}


		//build periodic other demand components time series (ex montly) starting from yearly other demand components
		ArrayList<Integer> tmpOtherDemandComponentsAdjustedForPeriodicity=new ArrayList<Integer>();
		for(int j=0;j<tmpOtherDemandComponentsInputs.size();j++){
			int tmpOtherComponents=tmpOtherDemandComponentsInputs.get(j);
			double tmpOtherComponentsAdjustedForPeriodicity=(double)(tmpOtherComponents/productionCycleLength);
			for(int z=1;z<productionCycleLength;z++){
				tmpOtherDemandComponentsAdjustedForPeriodicity.add((int)(tmpOtherComponentsAdjustedForPeriodicity));				
			}
			tmpOtherDemandComponentsAdjustedForPeriodicity.add(tmpOtherComponents-((int)tmpOtherComponentsAdjustedForPeriodicity*(productionCycleLength-1)));
		}

		//total periodic demand
		ArrayList<Integer> tmpDemandAdjustedForPeriodicity=new ArrayList<Integer>();

		//0.994
		tmpDemandAdjustedForPeriodicity.add(Integer.valueOf((int)(1.0*(tmpFoodDemandComponentAdjustedForPeriodicity.get(0)+tmpOtherDemandComponentsAdjustedForPeriodicity.get(0)))));
		tmpDemandAdjustedForPeriodicity.add(Integer.valueOf((int)(1.0*(tmpFoodDemandComponentAdjustedForPeriodicity.get(0)+tmpOtherDemandComponentsAdjustedForPeriodicity.get(0)))));
		for(int j=1;j<tmpFoodDemandComponentAdjustedForPeriodicity.size();j++){
			int tmpTotDemand=tmpFoodDemandComponentAdjustedForPeriodicity.get(j)+tmpOtherDemandComponentsAdjustedForPeriodicity.get(j);
			tmpDemandAdjustedForPeriodicity.add(Integer.valueOf(tmpTotDemand));
		}
//		System.out.println(parts[0]+" "+tmpFoodDemandComponentAdjustedForPeriodicity);
//		System.out.println(parts[0]+" "+tmpOtherDemandComponentsAdjustedForPeriodicity);	
//		System.out.println(parts[0]+" length of demand "+tmpDemandAdjustedForPeriodicity.size()+" length of pop "+tmpPopulationInputsAdjustedForPeriodicity.size());

		aBuyer=new Buyer(parts[0],parts[1],Double.valueOf(parts[2]),Double.valueOf(parts[3]),Double.valueOf(parts[4]),tmpPopulationInputsAdjustedForPeriodicity,tmpDemandAdjustedForPeriodicity,bidAndAskPrices);
		context.add(aBuyer);
		coord = new Coordinate(aBuyer.getLongitude(),aBuyer.getLatitude());
		geom = fac.createPoint(coord);
		geography.move(aBuyer, geom);
	}
	if(verboseFlag){
		System.out.println("");
	}

	
	//Markets creation


	marketsList=new ArrayList<Market>();

	try{
		lines=Files.readAllLines(Paths.get(System.getProperty("user.dir")+"/data/markets.csv"), Charset.forName("UTF-8"));
	} catch (IOException e) {
		e.printStackTrace();
	}
	for(int i=1;i<lines.size()-1;i++){
		String[] parts = ((String)lines.get(i)).split(",");
		aMarket=new Market(parts[0],Double.valueOf(parts[1]),Double.valueOf(parts[2]),Double.valueOf(parts[3]));
		marketsList.add(aMarket);
	}

	Collections.sort(marketsList,new MarketLongitudeComparator());

	if(verboseFlag){
		System.out.println();
		System.out.println("markets sorted according to their longitude");
	}
	for(Market aMarket : marketsList){
		if(verboseFlag){
			System.out.println("       market "+aMarket.getName()+" longitude "+aMarket.getLongitude());
		}
		context.add(aMarket);
		coord = new Coordinate(aMarket.getLongitude(),aMarket.getLatitude());
		geom = fac.createPoint(coord);
		geography.move(aMarket, geom);
	}





	//check markets and varieties

	String[] partsTmpMarkets=tmpMarkets.split("\\|");
	ArrayList<String> markets= new ArrayList<String>();
	markets.add(partsTmpMarkets[1]);
	for(int i=2;i<partsTmpMarkets.length;i++){
		boolean isPresent=false;
		for(int j=0;j<markets.size();j++){
			if(partsTmpMarkets[i].equals((String)markets.get(j))){
				isPresent=true;
			}
		}
		if(!isPresent){
			markets.add(partsTmpMarkets[i]);
		}
	}
	if(verboseFlag){
		System.out.println("");
		System.out.println("The following markets were found in the producers configuration file:");
		for(int j=0;j<markets.size();j++){
			System.out.println("     "+markets.get(j));
		}
		System.out.println("Please cross check that all the markets included in the markets configuration file are listed above");
		System.out.println("");
	}

	String[] partsTmpVarieties=tmpVarieties.split("\\|");
	ArrayList<String> varieties= new ArrayList<String>();
	varieties.add(partsTmpVarieties[1]);
	for(int i=2;i<partsTmpVarieties.length;i++){
		boolean isPresent=false;
		for(int j=0;j<varieties.size();j++){
			if(partsTmpVarieties[i].equals((String)varieties.get(j))){
				isPresent=true;
			}
		}
		if(!isPresent){
			varieties.add(partsTmpVarieties[i]);
		}
	}

	if(verboseFlag){
		System.out.println("The following products were found in the producers configuration file:");
		for(int j=0;j<varieties.size();j++){
			System.out.println("     "+varieties.get(j));
		}
		System.out.println("Please cross check against typos in configuration files");
		System.out.println("");
	}

	//Create Market sessions
	try{
		buyersList=context.getObjects(Class.forName("cms_wheat.agents.Buyer"));
		producersList=context.getObjects(Class.forName("cms_wheat.agents.Producer"));
	}
	catch(ClassNotFoundException e){
		System.out.println("Class not found");
	}
	for(int i=0;i<producersList.size();i++){
		aProducer=(Producer)producersList.get(i);
		String[] aProducerTmpMarkets=aProducer.getMarkets().split("\\|");
		for(int j=0;j<aProducerTmpMarkets.length;j++){
			for(int k=0;k<marketsList.size();k++){
				aMarket=(Market)marketsList.get(k);
				if(aProducerTmpMarkets[j].equals(aMarket.getName())){
					if(verboseFlag){
						System.out.println("MARKET "+aMarket.getName()+" ADD SESSIONS FOR "+aProducer.getName());
					}
					aMarket.addMarketSessions(aProducer,aProducer.getVarieties(),context,bidAndAskPrices);
				}
			}
		}
	}
	

	if(verboseFlag){
		System.out.println();
	}
	//setting buyers mustImportFlag
	for(int i=0;i<buyersList.size();i++){
		tmpMustImportFlag=true;
		aBuyer=(Buyer)buyersList.get(i);
		for(int j=0;j<producersList.size();j++){
			aProducer=(Producer)producersList.get(j);
			if(aProducer.getName().equals(aBuyer.getName())){
				tmpMustImportFlag=false;
			}
		}
		aBuyer.setMustImportFlag(tmpMustImportFlag);
	}
//loading crude oil prices
	
	try{
		lines=Files.readAllLines(Paths.get(System.getProperty("user.dir")+"/data/monthly_crude_oil_price.csv"), Charset.forName("UTF-8"));
	} catch (IOException e) {
		e.printStackTrace();
	}

		String[] parts = ((String)lines.get(1)).split(",");
		ArrayList<Double> tmpCrudeOilPricesInputs=new ArrayList<Double>();
		for(int j=1;j<parts.length;j++){
			tmpCrudeOilPricesInputs.add(Double.valueOf(parts[j]));
		}
		
	if(verboseFlag){
		System.out.println("Monthly oil price: "+tmpCrudeOilPricesInputs);
	}

	//System.out.println("Scheduling events");
	if(verboseFlag){
		System.out.println("");
	}
	schedule = RunEnvironment.getInstance().getCurrentSchedule();
	Cms_scheduler cms_schduler=new Cms_scheduler(context,tmpCrudeOilPricesInputs);
	cms_schduler.scheduleEvents();

	if(verboseFlag){
		System.out.println();
		System.out.println("===================================================================");
		System.out.println("END INITIALIZATION");
		System.out.println("====================================================================");
		System.out.println();
	}


	if (RunEnvironment.getInstance().isBatch())
	{
		RunEnvironment.getInstance().endAt(batchStoppingTime);
	}


	return context;
	}



}
