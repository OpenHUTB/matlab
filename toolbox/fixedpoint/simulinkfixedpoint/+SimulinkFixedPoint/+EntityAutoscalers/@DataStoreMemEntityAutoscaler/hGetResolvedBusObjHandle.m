function[busObjectHandle,asscociatedSigObj]=hGetResolvedBusObjHandle(h,blkObj,busObjHandleMap)









    asscociatedSigObj=[];
    [isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj);
    if isResolved
        asscociatedSigObj=slSignalInfo.object;
        dataTypeStr=asscociatedSigObj.DataType;
    else
        dataTypeStr=blkObj.OutDataTypeStr;
    end
    busObjName=h.hCleanBusName(dataTypeStr);

    if busObjHandleMap.isKey(busObjName)
        busObjectHandle=busObjHandleMap.getDataByKey(busObjName);
    else
        busObjectHandle=[];
    end



