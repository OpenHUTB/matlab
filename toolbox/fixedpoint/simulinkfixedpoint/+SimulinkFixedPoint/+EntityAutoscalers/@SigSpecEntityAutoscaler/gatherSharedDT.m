function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};


    sharedListsFromPort=hShareDataForSpecificPortsWithoutBus(h,blkObj,1,1);

    oneList=sharedListsFromPort;
    if blkObj.isSynthesized





        if~isempty(h.getActualSrcIDs(blkObj))

            signalObject=blkObj.CompiledSignalObject;
            if~isempty(signalObject)
                signalObjectName=blkObj.CompiledSignalObjectName;
                sigList.blkObj=SimulinkFixedPoint.SignalObjectWrapperCreator.getWrapper(...
                signalObject,signalObjectName,bdroot(blkObj.getFullName));
                sigList.pathItem=signalObjectName;
                oneList=[oneList,sigList];
            end
        end

    end

    OutDataTypeStr=get_param(blkObj.Handle,'OutDataTypeStr');
    ph=blkObj.PortHandles;


    isBus=(get_param(ph.Inport(1),'CompiledPortBusMode')==1);

    if~isBus



        sharedSamePortSrc=hShareSrcAtSamePort(h,blkObj);






        if length(sharedSamePortSrc)>1
            errorID='SimulinkFixedPoint:autoscaling:OnlySingleSharedDTListExpected';
            DAStudio.error(errorID);
        end
        if~isempty(sharedSamePortSrc)
            oneList=[oneList,sharedSamePortSrc{1}];
        end
    end

    if hIsVirtualBus(h,ph.Inport(1))&&...
        ~strcmp('Inherit: auto',OutDataTypeStr)&&...
        ~hIsStrResolveToBusObj(h,OutDataTypeStr,blkObj.Handle)





        shareAllSrcList=hShareDTAllInputVirBusSrcAndOutput(h,blkObj);
        if length(shareAllSrcList)~=1
            errorID='SimulinkFixedPoint:autoscaling:OnlySingleSharedDTListExpected';
            DAStudio.error(errorID);
        end
        oneList=[oneList,shareAllSrcList{1}];
    end

    if~isempty(oneList)
        sharedLists{1}=oneList;
    end





