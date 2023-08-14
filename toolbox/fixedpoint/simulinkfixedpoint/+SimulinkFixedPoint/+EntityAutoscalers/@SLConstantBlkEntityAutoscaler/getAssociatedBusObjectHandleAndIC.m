function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,~,busObjHandleMap)





    busObjHandleAndICList=[];


    ph=blkObj.PortHandles;


    busObjNameSet=containers.Map();
    ICValue=slResolve(blkObj.Value,blkObj.Handle);

    [sigH,isBus]=hGetBusSignalHierarchy(h,ph.Outport);

    if~isBus
        return;
    end

    isNonVirtualBus=h.hIsNonVirtualBus(ph.Outport);

    [busObjHandleAndICList,~]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
    ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet);



