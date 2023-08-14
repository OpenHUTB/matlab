


function processBlockData(datamgr,Config)


    ProfileBlockDataStage1=slci.internal.Profiler('SLCI',...
    'ProcessBlockResultsStage1',...
    '','');
    blockReader=datamgr.getBlockReader();
    incompReader=datamgr.getIncompatibilityReader();

    cs=incompReader.getKeys();
    incompatibilityObjects=cell(numel(cs),1);
    datamgr.beginTransaction();
    try
        for k=1:numel(cs)
            incompKey=cs{k};
            incompObj=incompReader.getObject(incompKey);
            objectsInvolved=incompObj.getObjectsInvolved();
            for p=1:numel(objectsInvolved)
                blockKey=objectsInvolved{p};
                if blockReader.hasObject(blockKey)
                    blockObj=blockReader.getObject(blockKey);
                    blockObj.setIncompatibilityKey(incompKey);
                    blockReader.replaceObject(blockKey,blockObj);
                end
            end
            incompatibilityObjects{k}=incompObj;
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();

    ProfileBlockDataStage1.stop();


    ProfileBlockDataStage2=slci.internal.Profiler('SLCI',...
    'ProcessBlockResultsStage2',...
    '','');
    blockReader=datamgr.getReader('BLOCK');
    dataKeys=blockReader.getKeys();
    dataObjects=blockReader.getObjects(dataKeys);
    numObjects=numel(dataObjects);
    for k=1:numObjects
        dataObject=dataObjects{k};
        if isa(dataObject,'slci.results.TransitionObject')


            slci.results.inheritDestInfo(dataObject,datamgr,Config);
        end
        dataObject.computeStatus(Config);
        dataObject.computeTraceStatus();
    end

    ProfileBlockDataStage2.stop();


    ProfileBlockDataStage3=slci.internal.Profiler('SLCI',...
    'ProcessBlockResultsStage3',...
    '','');
    numObjects=numel(dataObjects);
    datamgr.beginTransaction();
    try
        for k=1:numObjects
            dataObject=dataObjects{k};
            blockReader.replaceObject(dataObject.getKey(),dataObject);
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();




    slci.results.mapStatusOfNonVisibleObjects(dataObjects,blockReader,Config);

    ProfileBlockDataStage3.stop();

end
