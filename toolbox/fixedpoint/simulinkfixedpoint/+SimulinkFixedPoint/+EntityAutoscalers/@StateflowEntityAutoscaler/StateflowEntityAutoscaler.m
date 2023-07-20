classdef StateflowEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler




    methods
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
        associateRecords=gatherAssociatedParam(h,blkObj)
        [designMin,designMax,compiledDT,removeResult]=getModelCompiledDesignRange(h,blkObj,~)
        [isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)
    end


    methods(Hidden)
        [min,max]=gatherDesignMinMax(h,blkObj,pathItem)
        sharedLists=gatherSharedDT(h,blkObj)
        [DTConInfo,Comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
        blkContext=hGetValidContext(h,blkObj)
    end

end


