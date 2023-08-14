classdef BreakpointObjectEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler




    methods
        [minV,maxV]=gatherDesignMinMax(h,blkObj,pathItem);
        associateRecords=gatherAssociatedParam(h,blkObj);
        pathItems=getPathItems(h,blkObj);
        actualSrcIDs=getActualSrcIDs(h,blkObj);
        [hasDTConstraints,...
        DTConstraintsSet]=gatherDTConstraints(h,blkObj);
        [DTContInfo,comments,...
        paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
    end
    methods(Static)
        breakpointVector=getBreakpointData(breakpointObject);
        dataTypeCreator=getDataTypeCreator(breakpointObject);
    end
end


