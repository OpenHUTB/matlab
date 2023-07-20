function[isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)










    isResolved=blkObj.Props.ResolveToSignalObject;



    slSignalInfo=[];

    if isResolved

        blkContext=hGetValidContext(h,blkObj);
        chartId=sf('DataChartParent',blkContext.Id);
        chartH=sf('Private','chart2block',chartId);
        sigObj=slResolve(blkObj.Name,chartH,'expression','startUnderMask');

    elseif strcmp(blkObj.Scope,'Data Store Memory')

        DSMBlockHandle=slprivate('getDataStoreHandle',blkObj);
        if DSMBlockHandle~=-1
            if strcmpi(get_param(DSMBlockHandle,'StateMustResolveToSignalObject'),'on')
                isResolved=true;
                sigObj=slResolve(blkObj.Name,DSMBlockHandle);
            end
        end

    end

    if isResolved
        slSignalInfo.object=sigObj;
        slSignalInfo.name=blkObj.Name;
        dataHandler=fxptds.SimulinkDataArrayHandler;
        uniqueID=dataHandler.getUniqueIdentifier...
        (struct('Object',blkObj,'ElementName','1'));
        slSignalInfo.actualSrcID={uniqueID};
    end







