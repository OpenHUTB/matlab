classdef SLConstantBlkEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SLBusCapableBlkEntityAutoscaler










    methods(Hidden)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
    end

    methods
        [isForBlkParam,blkParamName]=isPathItemForBlockParam(h,srcBlk,pathItem)
    end
end


