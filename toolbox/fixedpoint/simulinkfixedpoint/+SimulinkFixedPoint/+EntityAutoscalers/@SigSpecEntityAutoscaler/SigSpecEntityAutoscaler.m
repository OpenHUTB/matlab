classdef SigSpecEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SLBusCapableBlkEntityAutoscaler









    methods
        [isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)
        pathItems=getPathItems(h,blkObj)
    end


    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
        sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
    end

end


