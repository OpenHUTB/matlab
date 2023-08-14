


classdef DataStoreRWEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SLBusCapableBlkEntityAutoscaler










    methods
        pathItems=getPathItems(h,blkObj)
        [isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)
    end


    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
    end

end


