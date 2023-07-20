function actualSrcIDs=getActualSrcIDs(h,blkObj)




    actualSrcIDSet=containers.Map;

    dataHandler=fxptds.SimulinkDataArrayHandler;

    inportHandles=blkObj.PortHandles.Inport;

    for i=1:length(inportHandles)
        portObj=get_param(inportHandles(i),'Object');
        [srcBlkObj,srcPathItem,srcInfo]=h.getSourceSignal(portObj);
        if~isempty(srcBlkObj)&&(isempty(srcInfo)||isempty(srcInfo.busObjectName))
            uniqueID=dataHandler.getUniqueIdentifier(struct('Object',srcBlkObj,'ElementName',srcPathItem));
            if~isempty(uniqueID)
                actualSrcIDSet(uniqueID.UniqueKey)=uniqueID;
            end
        end
    end
    actualSrcIDs=actualSrcIDSet.values;



