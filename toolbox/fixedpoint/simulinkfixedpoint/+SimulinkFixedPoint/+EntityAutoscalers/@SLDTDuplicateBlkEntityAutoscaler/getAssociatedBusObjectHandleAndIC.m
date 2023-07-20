function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)%#ok<INUSL>





    busObjHandleAndICList=[];














    ph=blkObj.PortHandles;
    portHandleVec=ph.Inport;

    [sigH,isBus]=hGetBusSignalHierarchy(h,portHandleVec(1));

    if~isBus

        return;
    end


    busObjNameSet=containers.Map();
    ICValue=[];
    if hIsNonVirtualBus(h,portHandleVec(1))




        isNonVirtualBus=true;
        [busObjHandleAndICList,~]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
        ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet);
        return;
    end


    isNonVirtualBus=false;
    for i=1:length(portHandleVec)
        [sigH,~]=hGetBusSignalHierarchy(h,portHandleVec(i));
        [newBusObjHandleAndICList,busObjNameSet]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
        ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet);
        busObjHandleAndICList=h.hAppendList(busObjHandleAndICList,...
        newBusObjHandleAndICList);
    end




