


classdef SLBusCapableBlkEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler















    methods
        sigH=hAttachBusObjectToSigH(h,sigH,busObjName,busObject,blkObj)



        isBusObj=hIsStrResolveToBusObj(h,str,hBlk)
        sharedLists=hShareDTAllInputVirBusSrcAndOutput(h,blkObj)
        sharedListPorts=hShareDataForSpecificPortsWithoutBus(h,blkObj,inportSet,outportSet)
    end


    methods(Hidden)
        busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)

        [isBusName,busName,busObj]=hGetBusNameThroughMask(h,busName,blkObj)
        pairList=hGetLeafChildBusEleAndSrcPairList(h,sigH,virBusSource,busObjHandleMap,alternateBusObjName)
        pairList=hGetMatchingPairListForTwoBusObjects(h,busObj1Name,busObj2Name,busObjHandleMap)
    end

end


