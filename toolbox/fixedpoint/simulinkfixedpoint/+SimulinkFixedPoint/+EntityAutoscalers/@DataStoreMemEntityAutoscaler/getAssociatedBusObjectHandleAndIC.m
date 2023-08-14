function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)%#ok




    busObjHandleAndICList=[];







    [busObjectHandle,asscociatedSigObj]=...
    hGetResolvedBusObjHandle(h,blkObj,busObjHandleMap);

    if isempty(busObjectHandle)
        return;
    end












    ICValue=slResolve(blkObj.InitialValue,blkObj.handle);
    if isempty(ICValue)&&~isempty(asscociatedSigObj)&&...
        ~isempty(asscociatedSigObj.InitialValue)
        ICValue=slResolve(asscociatedSigObj.InitialValue,blkObj.Handle);
    end

    isNonVirtualBus=true;
    sigH=hConstructSigHForBusObject(h,busObjectHandle.busName,busObjHandleMap);
    [busObjHandleAndICList,~]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
    ICValue,isNonVirtualBus,busObjHandleMap);







