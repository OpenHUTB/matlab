


classdef SLOutportBlkEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SLBusCapableBlkEntityAutoscaler








    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
        sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
    end

    methods(Hidden,Access=protected)
        y=hIsICApplicable(h,blkObj)
    end

end


