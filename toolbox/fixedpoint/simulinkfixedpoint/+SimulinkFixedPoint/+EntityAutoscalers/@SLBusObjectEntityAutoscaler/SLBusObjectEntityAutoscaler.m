classdef SLBusObjectEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler




    methods
        associateRecords=gatherAssociatedParam(h,blkObj)
    end

    methods(Hidden)
        comments=checkComments(h,blkObj,pathItem)
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
        [min,max]=gatherDesignMinMax(h,blkObj,pathItem)
        [DTConInfo,Comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
    end

end


