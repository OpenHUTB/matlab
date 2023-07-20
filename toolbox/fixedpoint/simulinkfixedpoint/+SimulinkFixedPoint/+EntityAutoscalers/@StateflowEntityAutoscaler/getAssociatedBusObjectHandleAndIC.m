function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)%#ok




    busObjHandleAndICList=[];







    busObjName=h.hCleanBusName(blkObj.CompiledType);

    if busObjHandleMap.isKey(busObjName)
        busObjectHandle=busObjHandleMap.getDataByKey(busObjName);
    else
        return;
    end



    ICValue=[];

    isNonVirtualBus=true;
    sigH=hConstructSigHForBusObject(h,busObjectHandle.busName,busObjHandleMap);
    [busObjHandleAndICList,~]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
    ICValue,isNonVirtualBus,busObjHandleMap);



