function sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)%#ok




    sharedLists={};








    outDataStr=blkObj.OutDataTypeStr;
    if strcmp(outDataStr,'Inherit: auto')
        return;
    end

    ph=blkObj.PortHandles;
    inportHandle=ph.Inport(1);


    if get_param(inportHandle,'CompiledPortBusMode')~=1

        return;
    end


    specifiedBusObj=h.hCleanBusName(outDataStr);
    [isBusName,specifiedBusObj,~]=hGetBusNameThroughMask(h,specifiedBusObj,blkObj);
    if~isBusName


        return;
    end


    inSigHier=get_param(inportHandle,'SignalHierarchy');
    sigHBusName=h.hCleanDTOPrefix(inSigHier.BusObject);


    portObj=get_param(inportHandle,'Object');



    if hIsNonVirtualBus(h,inportHandle)




        hidSrc=hGetHiddenNonVirBusSrc(h,portObj,false);
        if~isempty(hidSrc)
            sharedLists=h.hAppendToSharedLists(sharedLists,{hidSrc});
        end




    end


    if hIsVirtualBus(h,inportHandle)




        if isempty(sigHBusName)||strcmp(sigHBusName,specifiedBusObj)




            virBusSource=portObj.getActualSrcForVirtualBus;
            sharedLists=hGetLeafChildBusEleAndSrcPairList(h,...
            inSigHier,virBusSource,busObjHandleMap,specifiedBusObj);
        else




            sharedLists=hGetMatchingPairListForTwoBusObjects(h,...
            sigHBusName,specifiedBusObj,busObjHandleMap);
        end
    end


