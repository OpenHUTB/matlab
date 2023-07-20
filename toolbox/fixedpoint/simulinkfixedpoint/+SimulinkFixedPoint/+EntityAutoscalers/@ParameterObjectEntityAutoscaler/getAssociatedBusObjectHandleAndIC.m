function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,dataObjectWrapper,pathItem,busObjHandleMap)%#ok




    busObjHandleAndICList=[];





    DT=dataObjectWrapper.Object.DataType;
    if strcmp(DT,'auto')
        return;
    end
    busObjName=h.hCleanBusName(DT);
    if~busObjHandleMap.isKey(busObjName)
        return;
    end

    ICValue=dataObjectWrapper.Object.Value;

    sigH=hConstructSigHForBusObject(h,busObjName,busObjHandleMap);

    isNonVirtualBus=true;

    [busObjHandleAndICList,~]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
    ICValue,isNonVirtualBus,busObjHandleMap);







