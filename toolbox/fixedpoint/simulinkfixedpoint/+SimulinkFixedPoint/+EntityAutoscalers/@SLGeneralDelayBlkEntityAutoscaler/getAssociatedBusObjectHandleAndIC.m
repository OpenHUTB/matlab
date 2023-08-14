function busObjHandleAndICList=getAssociatedBusObjectHandleAndIC(h,blkObj,pathItem,busObjHandleMap)%#ok




    busObjHandleAndICList=[];











    ph=blkObj.PortHandles;

    [sigH,isBus]=hGetBusSignalHierarchy(h,ph.Outport(1));

    if~isBus

        return;
    end


    if isa(blkObj,'Simulink.Memory')||isa(blkObj,'Simulink.RateTransition')
        blockIC=slResolve(blkObj.X0,blkObj.Handle);
    elseif isa(blkObj,'Simulink.ZeroOrderHold')
        blockIC=[];
    else
        blockIC=slResolve(blkObj.InitialCondition,blkObj.Handle);
    end

    isNonVirtualBus=hIsNonVirtualBus(h,ph.Outport(1));

    [busObjHandleAndICList,~]=hGetAllBusObjHandleAndICListFromSigH(h,sigH,...
    blockIC,isNonVirtualBus,busObjHandleMap);




