function associateRecords=gatherAssociatedParam(h,blkObj)




    pathItems=getPathItems(h,blkObj);
    [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(h.getBreakpointData(blkObj.Object));
    associateRecords=SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blkObj,pathItems{1},[],minVal,maxVal,[]);
end


