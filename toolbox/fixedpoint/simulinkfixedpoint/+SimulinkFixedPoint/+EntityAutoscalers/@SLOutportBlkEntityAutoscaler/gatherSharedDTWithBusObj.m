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
    sigHBusNameAtBlkInput=h.hCleanDTOPrefix(inSigHier.BusObject);


    portObj=get_param(inportHandle,'Object');



    if hIsNonVirtualBus(h,inportHandle)




        hidSrc=hGetHiddenNonVirBusSrc(h,portObj,false);
        if~isempty(hidSrc)
            sharedLists=h.hAppendToSharedLists(sharedLists,{hidSrc});
        end







        if strcmp(sigHBusNameAtBlkInput,specifiedBusObj)




            [isBusName,newsigHBusName]=...
            getSrcSigHierarchyBusName(h,portObj,busObjHandleMap);
            if isBusName
                sigHBusName=newsigHBusName;
            else
                sigHBusName=sigHBusNameAtBlkInput;
            end
        else
            sigHBusName=sigHBusNameAtBlkInput;
        end


        if~strcmp(sigHBusName,specifiedBusObj)



            pairList=hGetMatchingPairListForTwoBusObjects(h,...
            sigHBusName,specifiedBusObj,busObjHandleMap);


            sharedLists=h.hAppendToSharedLists(sharedLists,pairList);
        end
    end


    if hIsVirtualBus(h,inportHandle)

        sigHBusName=sigHBusNameAtBlkInput;

        if isempty(sigHBusNameAtBlkInput)||strcmp(sigHBusName,specifiedBusObj)




            virBusSource=portObj.getActualSrcForVirtualBus;
            sharedLists=hGetLeafChildBusEleAndSrcPairList(h,...
            inSigHier,virBusSource,busObjHandleMap,specifiedBusObj);
        else




            sharedLists=hGetMatchingPairListForTwoBusObjects(h,...
            sigHBusName,specifiedBusObj,busObjHandleMap);
        end
    end


    function[isBusName,sigHBusName]=getSrcSigHierarchyBusName(h,portObj,...
        busObjHandleMap)


        isBusName=false;

        hSource=portObj.getActualSrc;
        if size(hSource(1,:),2)>3&&hSource(1,4)~=-1
            srcPortObj=get_param(hSource(1,1),'Object');
            attributes=srcPortObj.getCompiledAttributes(hSource(1,4));
            sigHBusName=h.hCleanBusName(attributes.dataType);
        else
            srcSigH=get_param(hSource(1),'SignalHierarchy');
            sigHBusName=h.hCleanBusName(srcSigH.BusObject);
        end
        if busObjHandleMap.isKey(sigHBusName)
            isBusName=true;
        end




