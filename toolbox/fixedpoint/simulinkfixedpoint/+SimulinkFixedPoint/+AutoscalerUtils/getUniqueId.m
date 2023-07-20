function uniqueId=getUniqueId(blkObj,pathItem)


    if(~isa(blkObj,'DAStudio.Object')&&~isa(blkObj,'Simulink.DABaseObject'))||~ischar(pathItem)
        uniqueId='';
    else
        thisPathItem=SimulinkFixedPoint.AutoscalerUtils.getBlkPathItemsFromPort(blkObj,[],pathItem);
        data=struct('Object',blkObj,'ElementName',thisPathItem{1});
        dHandler=fxptds.SimulinkDataArrayHandler;
        uniqueId=dHandler.getUniqueIdentifier(data);
    end
end
