


classdef DataStoreMemEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SLBusCapableBlkEntityAutoscaler









    methods
        [isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj)
    end


    methods(Hidden)
        associateRecords=gatherAssociatedParam(h,blkObj)
        sharedLists=gatherSharedDT(h,blkObj)
        sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)
        [busObjectHandle,asscociatedSigObj]=hGetResolvedBusObjHandle(h,blkObj,busObjHandleMap)
    end

end


