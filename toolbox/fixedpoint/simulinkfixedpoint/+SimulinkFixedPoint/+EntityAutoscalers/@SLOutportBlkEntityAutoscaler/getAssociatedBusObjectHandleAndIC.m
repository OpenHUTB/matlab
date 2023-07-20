function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)%#ok





    busObjHandleAndICList=[];






    ph=blkObj.PortHandles;

    [sigH,isBus]=hGetBusSignalHierarchy(h,ph.Inport(1));

    if~isBus

        return;
    end

    try
        blockIC=slResolve(blkObj.InitialOutput,blkObj.Handle);
    catch


        blockIC=[];
    end

    if~isempty(blockIC)

        if~h.hIsICApplicable(blkObj)
            blockIC=[];
        end
    end


    busObjNameSet=containers.Map();
    isNonVirtualBus=hIsNonVirtualBus(h,ph.Inport(1));

    [busObjHandleAndICList,busObjNameSet]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
    blockIC,isNonVirtualBus,busObjHandleMap,busObjNameSet);



    outDataStr=blkObj.OutDataTypeStr;
    if strcmp(outDataStr,'Inherit: auto')
        return;
    end





    specifiedBusObj=h.hCleanBusName(outDataStr);
    [isBusName,specifiedBusObj,busObj]=hGetBusNameThroughMask(h,specifiedBusObj,blkObj);
    if~isBusName


        return;
    end


    sigHBusName=h.hCleanDTOPrefix(sigH.BusObject);

    if~strcmp(sigHBusName,specifiedBusObj)



        newSigH=sigH;
        newSigH=hAttachBusObjectToSigH(h,newSigH,specifiedBusObj,busObj,blkObj);

        [newBusObjHandleAndICList,~]=hGetAllBusObjHandleAndICListFromSigH(h,newSigH,...
        blockIC,isNonVirtualBus,busObjHandleMap,busObjNameSet);
        busObjHandleAndICList=h.hAppendList(busObjHandleAndICList,...
        newBusObjHandleAndICList);
    end



