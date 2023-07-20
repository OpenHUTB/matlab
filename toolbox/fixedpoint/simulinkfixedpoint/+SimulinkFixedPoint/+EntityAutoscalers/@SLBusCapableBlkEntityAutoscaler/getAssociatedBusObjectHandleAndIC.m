function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)





    busObjHandleAndICList=[];


    blkPathItems=h.getPathItems(blkObj);
    if~strcmp(blkPathItems{1},pathItem)
        return;
    end


    ph=blkObj.PortHandles;
    portHandleVec=[ph.Inport,ph.Outport];

    busObjNameSet=containers.Map();
    ICValue=[];

    for i=1:length(portHandleVec)

        [sigH,isBus]=hGetBusSignalHierarchy(h,portHandleVec(i));

        if~isBus
            continue;
        end


        isNonVirtualBus=h.hIsNonVirtualBus(portHandleVec(i));

        [newBusObjHandleAndICList,busObjNameSet]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
        ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet);
        busObjHandleAndICList=h.hAppendList(busObjHandleAndICList,...
        newBusObjHandleAndICList);

    end



