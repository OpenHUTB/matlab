function complexPlotID=getComplexSignalPlotID(signalRootID)



    aFactory=starepository.repositorysignal.Factory;
    concreteExtractor=aFactory.getSupportedExtractor(signalRootID);

    plottableIDs=getPlottableSignalIDs(concreteExtractor,signalRootID);
    complexPlotID=plottableIDs(1);
