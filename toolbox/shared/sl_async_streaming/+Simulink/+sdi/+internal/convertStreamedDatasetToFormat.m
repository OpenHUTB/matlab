function data=convertStreamedDatasetToFormat(mdl,data,fmt,domain)





    assert(slfeature('StateLoggingThroughJetstream'));
    assert(strcmp(domain,'state')||strcmp(domain,'final_state'));
    assert(~strcmp(fmt,'dataset'));

    repo=sdi.Repository(1);
    runID=Simulink.sdi.internal.getRunIDfromLoggedData(data);



    if isempty(runID)
        runID=Simulink.HMI.getCurrentCachedRunID(repo,mdl);
    end

    if isempty(runID)
        runID=repo.getCurrentStreamingRunID(mdl);
    end


    dsr=Simulink.sdi.DatasetRef(runID,domain);
    dsr.SortStatesForLegacyFormats=true;

    storage=getStorage(data,false);
    if isa(storage,'Simulink.sdi.internal.DatasetStorage')

        storage.setSortStatesForLegacyFormats(true);
        data=loadIntoMemory(data);
    else




        data=dsr.fullExport();
    end

    sigIDs=dsr.getSortedSignalIDs();
    data=Simulink.sdi.internal.convertToFormat(data,fmt,sigIDs);
end
