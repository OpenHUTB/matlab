function discoverResults(~,runObj,modelObject,modelName)












    asExtension=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();

    [activeBlkList,inactiveBlkList]=SimulinkFixedPoint.AutoscalerUtils.getAllBlockList(modelObject);

    activeBlkList=num2cell(activeBlkList)';
    lookupTableObjectWrappers=SimulinkFixedPoint.AutoscalerUtils.getLookupObjectWrappers(modelName,'Simulink.LookupTable');
    breakpointObjectWrappers=SimulinkFixedPoint.AutoscalerUtils.getLookupObjectWrappers(modelName,'Simulink.Breakpoint');
    activeBlkList=[activeBlkList,lookupTableObjectWrappers,breakpointObjectWrappers];


    slDataArrayHandler=fxptds.SimulinkDataArrayHandler;
    allResults=runObj.getResults;
    for i=1:length(activeBlkList)
        curBlk=activeBlkList{i};
        blkAutoscaler=asExtension.getAutoscaler(curBlk);
        pathItems=blkAutoscaler.getPathItems(curBlk);

        if~isempty(pathItems)
            for jj=1:length(pathItems)
                identifier=slDataArrayHandler.getUniqueIdentifier(struct('Object',curBlk,'ElementName',pathItems{jj}));
                [results,numAdded]=runObj.findResultFromArrayOrCreate({'UniqueIdentifier',identifier});%#ok<*AGROW>
                if numAdded>0
                    if isempty(allResults)
                        allResults=results;
                    else
                        allResults(end+1)=results;
                    end
                end
            end
        end
    end







    [activeSFDataList,inactiveSFDataList]=SimulinkFixedPoint.AutoscalerUtils.getAllStateflowDataList(modelObject);
    allResults=runObj.getResults();
    for j=1:length(activeSFDataList)
        sfDataParent=activeSFDataList(j).getParent;


        if~isa(sfDataParent,'Stateflow.SLFunction')
            [results,~,numAdded]=runObj.findResultForBlockFromArrayOrCreate(activeSFDataList(j));
            if numAdded>0
                if isempty(allResults)
                    allResults=results;
                else
                    allResults(end+1)=results;
                end
            end
        end
    end

    inactiveList=[inactiveBlkList(:);inactiveSFDataList(:)];


    for m=1:length(inactiveList)
        blkAutoscaler=asExtension.getAutoscaler(inactiveList(m));
        pathItems=blkAutoscaler.getPathItems(inactiveList(m));
        if isempty(pathItems)
            pathItems={'1'};
        end
        for k=1:numel(pathItems)
            filteredResult=runObj.getResult(inactiveList(m),pathItems{k});
            if~isempty(filteredResult)
                runObj.clearResultFromRun(filteredResult);
            end
        end
    end

    SimulinkFixedPoint.Autoscaler.addCompiledBlocksToDataset(runObj,modelName);
    runObj.deleteInvalidResults();
end