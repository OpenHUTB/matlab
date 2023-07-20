function[isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)










    isResolved=false;

    slSignalInfo=[];

    try
        blockType=blkObj.BlockType;
    catch
        return;
    end

    switch blockType
    case{'DiscreteFilter','DiscreteTransferFcn','DiscreteIntegrator','DiscreteZeroPole',...
        'Memory','Delay','UnitDelay'}
        if strcmp(blkObj.StateMustResolveToSignalObject,'on')

            isResolved=true;
            sigName=blkObj.StateIdentifier;
            slSignalInfo.object=slResolve(sigName,blkObj.Handle);
            slSignalInfo.name=sigName;
            slSignalInfo.actualSrcID=h.getActualSrcIDs(blkObj);
        end
    end
    if isResolved
        dataHandler=fxptds.SimulinkDataArrayHandler;
        switch blockType
        case{'DiscreteFilter','DiscreteTransferFcn'}
            uniqueID=dataHandler.getUniqueIdentifier(struct('Object',blkObj,'ElementName','States'));
        case{'DiscreteIntegrator','DiscreteZeroPole'}
            blkID=SimulinkFixedPoint.AutoscalerUtils.getSignalDrivingPort(h,blkObj,[],1);
            uniqueID=dataHandler.getUniqueIdentifier(struct('Object',blkID{1}.blkObj,'ElementName',blkID{1}.pathItem));
        case{'Memory','Delay','UnitDelay'}
            uniqueID=dataHandler.getUniqueIdentifier(struct('Object',blkObj,'ElementName','1'));
        end
        slSignalInfo.actualSrcID={uniqueID};
    end









