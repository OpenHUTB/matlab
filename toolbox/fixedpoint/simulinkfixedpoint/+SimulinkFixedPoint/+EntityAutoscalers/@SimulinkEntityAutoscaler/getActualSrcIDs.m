function actualSrcIDs=getActualSrcIDs(h,blkObj)





    actualSrcIDSet=containers.Map;

    dataHandler=fxptds.SimulinkDataArrayHandler;


    if isa(blkObj,'Simulink.Inport')&&...
        ~isa(get_param(blkObj.Parent,'Object'),'Simulink.BlockDiagram')
        [srcBlkObj,srcPathItem,srcInfo]=h.getSourceSignal(blkObj);
        if~isempty(srcBlkObj)&&(isempty(srcInfo)||isempty(srcInfo.busObjectName))
            uniqueID=dataHandler.getUniqueIdentifier(struct('Object',srcBlkObj,'ElementName',srcPathItem));
            actualSrcIDSet(uniqueID.UniqueKey)=uniqueID;
        end
    end

    inportHandles=blkObj.PortHandles.Inport;

    for i=1:length(inportHandles)
        portObj=get_param(inportHandles(i),'Object');
        [srcBlkObj,srcPathItem,srcInfo]=h.getSourceSignal(portObj);
        uniqueID=dataHandler.getUniqueIdentifier(struct('Object',srcBlkObj,'ElementName',srcPathItem));
        if~isempty(srcBlkObj)&&(isempty(srcInfo)||isempty(srcInfo.busObjectName))
            actualSrcIDSet(uniqueID.UniqueKey)=uniqueID;
        end
    end

    actualSrcIDs=actualSrcIDSet.values;