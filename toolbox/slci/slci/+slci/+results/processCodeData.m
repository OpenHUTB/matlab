



function processCodeData(datamgr,Config)


    ProfileCodeStage1=slci.internal.Profiler('SLCI','ProcessCodeResultsStage1',...
    '','');

    codeReader=datamgr.getReader('CODE');
    funcInterfaceReader=datamgr.getReader('FUNCTIONINTERFACE');

    clocations=codeReader.getKeys();
    cObjects=codeReader.getObjects(clocations);
    numLocations=numel(cObjects);


    cObjects=slci.results.deriveFunctionScope(cObjects,datamgr);

    ProfileCodeStage1.stop();

    ProfileCodeStage2=slci.internal.Profiler('SLCI','ProcessCodeResultsStage2',...
    '','');

    datamgr.beginTransaction();
    try
        for k=1:numLocations
            cObject=cObjects{k};
            if isempty(cObject.getPrimVerSubstatus())&&...
                cObject.getVerificationInfo().IsEmpty()
                deriveVerSubstatus(cObject,funcInterfaceReader);
            end
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();

    ProfileCodeStage2.stop();


    ProfileCodeStage3=slci.internal.Profiler('SLCI','ProcessCodeResultsStage3',...
    '','');

    modelReader=datamgr.getBlockReader();
    predicate=@(x)isa(x,'slci.results.ModelObject')&&~getIsVisible(x);
    [nvModelKeys,nvModelObjs]=slci.results.getObjects(modelReader,...
    predicate);
    if~isempty(nvModelKeys)
        nonVisibleMap=containers.Map(nvModelKeys,nvModelObjs);
    else
        nonVisibleMap=containers.Map;
    end


    for k=1:numLocations
        cObject=cObjects{k};
        cObject.computeStatus(Config);


        cObject=filterNonVisibleTracedObjects(cObject,nonVisibleMap);
        cObject.computeTraceStatus();
    end
    ProfileCodeStage3.stop();


    ProfileCodeStage4=slci.internal.Profiler('SLCI','ProcessCodeResultsStage4',...
    '','');


    datamgr.beginTransaction();
    try
        for k=1:numLocations
            cObject=cObjects{k};
            codeReader.replaceObject(cObject.getKey(),cObject);
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();

    ProfileCodeStage4.stop();


    codeSliceReader=datamgr.getCodeSliceReader();
    codeSliceObjects=codeSliceReader.getObjects(...
    codeSliceReader.getKeys());
    numCodeSlices=numel(codeSliceObjects);

    ProfileCodeStage5=slci.internal.Profiler('SLCI','ProcessCodeResultsStage5',...
    '','');
    for k=1:numCodeSlices
        sliceObj=codeSliceObjects{k};
        sliceObj.computeStatus(datamgr,Config);
    end

    ProfileCodeStage5.stop();


    ProfileCodeStage6=slci.internal.Profiler('SLCI','ProcessCodeResultsStage6',...
    '','');

    datamgr.beginTransaction();
    try
        for k=1:numCodeSlices
            sliceObj=codeSliceObjects{k};
            codeSliceReader.replaceObject(sliceObj.getKey(),sliceObj);
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();

    ProfileCodeStage6.stop();

end


function cObject=filterNonVisibleTracedObjects(cObject,nvObjects)

    traced=cObject.getTraceArray();
    if~isempty(traced)

        visibleTraced=cellfun(@(x)getVisibleTarg(x,nvObjects),...
        traced,'UniformOutput',false);
        if~iscell(visibleTraced)
            visibleTraced={visibleTraced};
        end
        cObject.setTraceKey(unique(visibleTraced,'sorted'));
    end
end


function visibleTarget=getVisibleTarg(blockKey,nvObjects)

    if isKey(nvObjects,blockKey)

        nvObj=nvObjects(blockKey);
        target=nvObj.getVisibleTarget();
        assert(numel(target)==1);
        visibleTarget=getVisibleTarg(target{1},nvObjects);
    else
        visibleTarget=blockKey;
    end
end



function deriveVerSubstatus(cObject,funcInterfaceReader)

    traceKeys=cObject.getTraceArray;
    numTraceKeys=numel(traceKeys);
    functionKeys=funcInterfaceReader.getKeys();
    for k=1:numTraceKeys
        thisKey=traceKeys{k};
        if any(strcmp(functionKeys,thisKey))
            funcObject=funcInterfaceReader.getObject(thisKey);

            status=funcObject.getStatus();
            if strcmp(status,'UNKNOWN')
                funcObject.computeStatus();
                status=funcObject.getStatus();
            end



            switch status
            case 'VERIFIED'
                cObject.addPrimVerSubstatus('PASSED')
            case{'FAILED_TO_VERIFY','PARTIALLY_VERIFIED'}
                cObject.addPrimVerSubstatus('FAILED_TO_VERIFY')
            otherwise


            end
        end
        return;
    end
end
