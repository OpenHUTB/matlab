function sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)%#ok




    sharedLists={};









    if strcmp(blkObj.OutDataTypeStr,'Inherit: auto')
        return;
    end

    ph=blkObj.PortHandles;


    outSigHier=get_param(ph.Outport(1),'SignalHierarchy');
    busObjectForOutput=outSigHier.BusObject;







    cleanedBusName=h.hCleanDTOPrefix(busObjectForOutput);

    busOBjHandle=hGetBusObjHandleFromMap(h,...
    cleanedBusName,busObjHandleMap);




    inportHandles=ph.Inport;
    for inportIndex=1:length(inportHandles)

        inportHandle=inportHandles(inportIndex);

        portObj=get_param(inportHandle,'Object');


        if portObj.CompiledPortBusMode~=1


            [busSrcSigID.blkObj,busSrcSigID.pathItem,busSrcSigID.srcInfo]=...
            getSourceSignal(h,portObj,false);
            if~isempty(busSrcSigID.blkObj)&&~isempty(busSrcSigID.pathItem)


                busObjSigID.pathItem=...
                busOBjHandle.elementNames{inportIndex};
                busObjSigID.blkObj=busOBjHandle;
                pair={busSrcSigID,busObjSigID};
                sharedLists=h.hAppendToSharedLists(sharedLists,pair);
            end
        end




        if hIsNonVirtualBus(h,inportHandle)

            hidSrc=hGetHiddenNonVirBusSrc(h,portObj,false);

            if~isempty(hidSrc)

                sharedLists=h.hAppendToSharedLists(sharedLists,{hidSrc});
            end
            continue;
        end


        if hIsVirtualBus(h,inportHandle)

            inportSigH=get_param(inportHandle,'SignalHierarchy');


            virBusSource=portObj.getActualSrcForVirtualBus;


            pairList=hGetLeafChildBusEleAndSrcPairList(h,...
            inportSigH,virBusSource,busObjHandleMap,[]);


            sharedLists=h.hAppendToSharedLists(sharedLists,pairList);
            continue;
        end
    end


