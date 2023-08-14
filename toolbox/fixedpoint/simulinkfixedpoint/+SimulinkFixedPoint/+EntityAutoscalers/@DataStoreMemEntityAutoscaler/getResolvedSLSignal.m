function[isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)%#ok












    slSignalInfo=[];

    isResolved=strcmpi(blkObj.StateMustResolveToSignalObject,'on');

    if isResolved

        slSignalInfo.object=slResolve(blkObj.DataStoreName,blkObj.Handle);
        slSignalInfo.name=blkObj.DataStoreName;

        dataHandler=fxptds.SimulinkDataArrayHandler;
        uniqueID=dataHandler.getUniqueIdentifier...
        (struct('Object',blkObj,'ElementName','1'));
        slSignalInfo.actualSrcID={uniqueID};
    end






