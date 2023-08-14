


classdef SLBusAssignmentBlkEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SLBusCapableBlkEntityAutoscaler








    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
        sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
    end

end


