function sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)%#ok




    sharedLists={};






    ph=blkObj.PortHandles;
    inportHandle=ph.Inport(1);


    if get_param(inportHandle,'CompiledPortBusMode')~=1

        return;
    end


    if hIsNonVirtualBus(h,inportHandle)


        portObj=get_param(inportHandle,'Object');
        hidSrc=hGetHiddenNonVirBusSrc(h,portObj,false);
        if~isempty(hidSrc)
            sharedLists=h.hAppendToSharedLists(sharedLists,{hidSrc});
        end
        return;
    end



    if strcmp(blkObj.ConversionOutput,'Nonvirtual bus')&&...
        hIsVirtualBus(h,inportHandle)

        portObj=get_param(inportHandle,'Object');


        virBusSource=portObj.getActualSrcForVirtualBus;


        outSigHier=get_param(inportHandle,'SignalHierarchy');


        sharedLists=hGetLeafChildBusEleAndSrcPairList(h,...
        outSigHier,virBusSource,busObjHandleMap,[]);
    end





