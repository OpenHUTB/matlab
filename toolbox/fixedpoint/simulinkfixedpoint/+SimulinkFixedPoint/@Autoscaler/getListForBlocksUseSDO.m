function[blkSDOPair]=getListForBlocksUseSDO(topSubsysToScale)








    mdl=bdroot(topSubsysToScale.getFullName);
    appData=SimulinkFixedPoint.getApplicationData(mdl);
    SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();

    runObj=appData.dataset.getRun(appData.ScaleUsing);
    aScalerData=runObj.getMetaData;
    if isa(aScalerData,'fxptds.AutoscalerMetaData')
        aScalerData.clearResultListForAllSources;
    end
    allResults=runObj.getResults;



    sfData=find(topSubsysToScale,'-isa','Stateflow.Data');
    for j=1:length(sfData)
        sfDataParent=sfData(j).getParent;

        if~isa(sfDataParent,'Stateflow.SLFunction')&&~isa(sfDataParent,'Stateflow.EMChart')
            data=struct('Object',sfData(j));
            dHandler=fxptds.SimulinkDataArrayHandler;
            [addedResult,numAdded]=runObj.findResultFromArrayOrCreate({'UniqueIdentifier',dHandler.getUniqueIdentifier(data)});
            if numAdded>0
                if~isempty(allResults)
                    allResults(end+1)=addedResult;%#ok<*AGROW>
                else
                    allResults=addedResult;
                end
            end
        end
    end


    dsMemBlk=[findobj(topSubsysToScale,'-isa','Simulink.DataStoreMemory')];
    for j=1:length(dsMemBlk)
        data=struct('Object',dsMemBlk(j));
        dHandler=fxptds.SimulinkDataArrayHandler;
        [addedResult,numAdded]=runObj.findResultFromArrayOrCreate({'UniqueIdentifier',dHandler.getUniqueIdentifier(data)});
        if numAdded>0
            if~isempty(allResults)
                allResults(end+1)=addedResult;%#ok<*AGROW>
            else
                allResults=addedResult;
            end
        end
    end


    isCompileLocally=false;
    if strcmp(get_param(mdl,'SimulationStatus'),'stopped')
        isCompileLocally=true;
        try
            interface=get_param(mdl,'ObjectAPI_FP');
            init(interface,'MODEL_API');
        catch
            slfeature('EngineInterface',0);
            DAStudio.error('SimulinkFixedPoint:autoscaling:engineInterfaceFail');
        end
    end


    SimulinkFixedPoint.Autoscaler.addCompiledBlocksToDataset(runObj,mdl);

    r=runObj.getResults;

    for i=1:length(r)
        r(i).clearProposalData;
    end
    blkSDOPair={};

    for i=1:length(r)
        try
            curRecord=r(i);
            currentAutoscaler=curRecord.getAutoscaler;
            blkObj=curRecord.UniqueIdentifier.getObject;
            curActualSrcIDs=currentAutoscaler.getActualSrcIDs(blkObj);
            if~isempty(curActualSrcIDs)
                [resultAdded,numAdded]=SimulinkFixedPoint.Autoscaler.addToSrcList(runObj,curRecord,curActualSrcIDs);
                if numAdded
                    r(end+(1:numAdded))=resultAdded;
                end
            end



            blkPathItems=currentAutoscaler.getPathItems(blkObj);

            if isempty(blkPathItems)||strcmp(blkPathItems{1},curRecord.getElementName)
                [isResolved,slSignalInfo]=currentAutoscaler.getResolvedSLSignal(blkObj);

                if isResolved
                    [sdoResult,numAdded]=SimulinkFixedPoint.Autoscaler.createSDOResult(runObj,slSignalInfo,mdl);
                    if~isempty(sdoResult)
                        r(end+(1:numAdded))=sdoResult;
                        if~isempty(slSignalInfo.actualSrcID)
                            SimulinkFixedPoint.Autoscaler.addToSrcList(runObj,sdoResult,slSignalInfo.actualSrcID);
                        end
                    end
                end
            end

        catch e %#ok

        end
    end

    if isCompileLocally

        try
            term(interface);
            slfeature('EngineInterface',0);
        catch

            errorID='SimulinkFixedPoint:autoscaling:engineInterfaceFail';
            DAStudio.error(errorID);
        end
    end


    allSDOResult=[];
    if~isempty(r)
        for i=1:numel(r)
            if isa(r(i),'fxptds.SignalObjectResult')
                allSDOResult=[allSDOResult,r(i)];
            end
        end
    else
        allSDOResult=[];
    end
    dh=fxptds.SimulinkDataArrayHandler;
    mdata=struct('Object',topSubsysToScale);
    sysID=dh.getUniqueIdentifier(mdata);
    for idx=1:length(allSDOResult)
        if allSDOResult(idx).isWithinProvidedScope(sysID)
            curActualSrcIDList=allSDOResult(idx).getActualSourceIDs;
            for j=1:numel(curActualSrcIDList)
                actualSrcResult=runObj.findResultFromArrayOrCreate({'UniqueIdentifier',curActualSrcIDList{j}});
                blkSDOPair{end+1}=[allSDOResult(idx),actualSrcResult];
            end
        end
    end


