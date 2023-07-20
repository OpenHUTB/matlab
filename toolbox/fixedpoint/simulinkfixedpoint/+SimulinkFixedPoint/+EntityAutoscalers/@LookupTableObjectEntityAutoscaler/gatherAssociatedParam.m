function associateRecords=gatherAssociatedParam(h,blkObj)




    pathItems=getPathItems(h,blkObj);
    associateRecords=[];
    [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(h.getTableData(blkObj.Object));
    associateRecord=SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blkObj,'Table',[],minVal,maxVal,[]);
    associateRecords=[associateRecords,associateRecord];

    nPathItems=numel(pathItems);
    if nPathItems>1
        for ii=2:nPathItems
            breakpointVector=SimulinkFixedPoint.EntityAutoscalers.LookupTableObjectEntityAutoscaler.getBreakpointData(blkObj.Object,ii-1);
            [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(breakpointVector);
            associateRecord=SimulinkFixedPoint.EntityAutoscalerUtils.createRecordForAssociatedParam(blkObj,pathItems{ii},[],minVal,maxVal,[]);
            associateRecords=[associateRecords,associateRecord];%#ok<AGROW>
        end
    end
end


