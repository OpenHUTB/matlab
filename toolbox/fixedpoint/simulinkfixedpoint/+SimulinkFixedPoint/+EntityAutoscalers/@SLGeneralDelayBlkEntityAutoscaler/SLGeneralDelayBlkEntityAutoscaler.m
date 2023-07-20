


classdef SLGeneralDelayBlkEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SLBusCapableBlkEntityAutoscaler








    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
    end

end


