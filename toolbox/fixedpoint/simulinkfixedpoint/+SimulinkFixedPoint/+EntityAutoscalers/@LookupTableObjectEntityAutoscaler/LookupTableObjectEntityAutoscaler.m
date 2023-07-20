classdef(Sealed)LookupTableObjectEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler




    methods
        [minV,maxV]=gatherDesignMinMax(h,blkObj,pathItem);
        associateRecords=gatherAssociatedParam(h,blkObj);
        pathItems=getPathItems(h,blkObj);
        actualSrcIDs=getActualSrcIDs(h,blkObj);
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
        [sharedLists]=gatherSharedDT(h,blkObj);
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj);
        [DTContInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem);
    end

    methods(Static)
        breakpointVector=getBreakpointData(lookTableObject,dimension);
        index=getIndexFromBreakpointPathitem(breakpointPathItem);
        tableData=getTableData(lookupTableObject);
        dataTypeCreator=getDataTypeCreator(lookupTableObject,dimension);
    end
end


