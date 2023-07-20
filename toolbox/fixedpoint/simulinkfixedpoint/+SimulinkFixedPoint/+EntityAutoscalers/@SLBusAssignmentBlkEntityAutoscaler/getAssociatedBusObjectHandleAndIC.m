function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)%#ok




    busObjHandleAndICList=[];










    ph=blkObj.PortHandles;


    [sigH,isBus]=hGetBusSignalHierarchy(h,ph.Outport(1));

    if~isBus
        return;
    end


    ICValue=[];
    isNonVirtualBus=h.hIsNonVirtualBus(ph.Outport(1));

    [busObjHandleAndICList,~]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
    ICValue,isNonVirtualBus,busObjHandleMap);



