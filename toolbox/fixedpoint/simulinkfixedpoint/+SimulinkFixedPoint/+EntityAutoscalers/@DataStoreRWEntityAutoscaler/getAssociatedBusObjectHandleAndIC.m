function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)




    busObjHandleAndICList=[];


    blkPathItems=h.getPathItems(blkObj);
    if~strcmp(blkPathItems{1},pathItem)
        return;
    end


    ph=blkObj.PortHandles;
    portHandleVec=[ph.Inport,ph.Outport];

    busObjNameSet=containers.Map();
    busObjHandleAndICList=[];
    isNonVirtualBus=true;
    ICValue=[];
    for i=1:length(portHandleVec)

        [sigH,isBus]=hGetBusSignalHierarchy(h,portHandleVec(i));

        if~isBus
            continue;
        end

        [newBusObjHandleAndICList,busObjNameSet]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
        ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet);
        busObjHandleAndICList=h.hAppendList(busObjHandleAndICList,...
        newBusObjHandleAndICList);
    end



    dataStoreHandle=slprivate('getDataStoreHandle',blkObj);
    if dataStoreHandle==-1
        errorID='SimulinkFixedPoint:autoscaling:DSMNotFound';
        DAStudio.error(errorID,blkObj.getFullName);
    end

    dataStoreObj=get_param(dataStoreHandle,'Object');

    [isResolved,slSignalInfo]=getResolvedSLSignal(h,blkObj);
    if isResolved
        sigObj=slSignalInfo.object;
        dataTypeStr=sigObj.DataType;
    else
        dataTypeStr=dataStoreObj.OutDataTypeStr;
    end

    busObjName=h.hCleanBusName(dataTypeStr);

    if~busObjHandleMap.isKey(busObjName)

        return;
    end

    sigH=hConstructSigHForBusObject(h,busObjName,busObjHandleMap);
    [newBusObjHandleAndICList,~]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
    ICValue,isNonVirtualBus,busObjHandleMap,busObjNameSet);

    busObjHandleAndICList=h.hAppendList(busObjHandleAndICList,...
    newBusObjHandleAndICList);




