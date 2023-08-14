


function processResults(Config,reportConfig)


    ProfileResults=slci.internal.Profiler('SLCI','PostprocessResults',...
    Config.getModelName(),...
    Config.getTargetName());


    slci.results.convertResults(Config);

    datamgr=Config.getDataManager();
    slci.results.processFunctionData(datamgr);


    slci.results.processBlockData(datamgr,Config);
    slci.results.processCodeData(datamgr,Config);
    slci.results.processFunctionBodyData(datamgr);


    slci.results.aggregateResults(datamgr,reportConfig,Config);


    ProfileResults.stop();
end
