function[isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)%#ok<INUSL>












    slSignalInfo=[];

    dataStoreHandle=slprivate('getDataStoreHandle',blkObj);

    DSMBlkObj=get_param(dataStoreHandle,'Object');

    isResolved=strcmpi(DSMBlkObj.StateMustResolveToSignalObject,'on');

    if isResolved

        slSignalInfo.object=slResolve(DSMBlkObj.DataStoreName,dataStoreHandle);
        slSignalInfo.name=DSMBlkObj.DataStoreName;
        dataHandler=fxptds.SimulinkDataArrayHandler;






        uniqueID=dataHandler.getUniqueIdentifier...
        (struct('Object',blkObj,'ElementName','1'));
        slSignalInfo.actualSrcID={uniqueID};
    end




