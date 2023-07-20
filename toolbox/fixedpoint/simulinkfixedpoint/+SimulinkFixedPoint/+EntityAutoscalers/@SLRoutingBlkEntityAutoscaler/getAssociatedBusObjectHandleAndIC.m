function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)%#ok





    busObjHandleAndICList=[];






    ph=blkObj.PortHandles;
    portHandleVec=ph.Inport;


    if isa(blkObj,'Simulink.Merge')
        blockIC=slResolve(blkObj.InitialOutput,blkObj.Handle);
    else
        blockIC=[];
    end

    busObjNameSet=containers.Map();
    isNonVirtualBus=hIsNonVirtualBus(h,portHandleVec(1));


    for i=1:length(portHandleVec)

        [sigH,isBus]=hGetBusSignalHierarchy(h,portHandleVec(i));
        if~isBus

            continue;
        end


        [newBusObjHandleAndICList,busObjNameSet]=...
        hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
        blockIC,isNonVirtualBus,busObjHandleMap,busObjNameSet);
        busObjHandleAndICList=h.hAppendList(busObjHandleAndICList,...
        newBusObjHandleAndICList);

        if isNonVirtualBus




            return;
        end
    end


