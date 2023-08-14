classdef SLSignalEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler




    methods
        associateRecords=gatherAssociatedParam(h,blkObj)
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
    end


    methods(Hidden)
        [min,max]=gatherDesignMinMax(h,blkObj,pathItem)
        [DTConInfo,Comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
    end

end


