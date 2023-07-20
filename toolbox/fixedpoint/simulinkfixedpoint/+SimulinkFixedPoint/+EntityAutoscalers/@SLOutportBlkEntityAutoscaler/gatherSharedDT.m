function sharedLists=gatherSharedDT(h,blkObj)


    sharedLists={};

    hPorts=blkObj.Porthandles;







    isNotBus=~(get_param(hPorts.Inport(1),'CompiledPortBusMode')==1);
    if isNotBus||hIsNonVirtualBus(h,hPorts.Inport(1))
        portObj=get_param(hPorts.Inport(1),'Object');
        [srcBlkObj,srcPathItem,srcInfo]=h.getSourceSignal(portObj);
        structSignalID.blkObj=srcBlkObj;
        structSignalID.pathItem=srcPathItem;
        structSignalID.srcInfo=srcInfo;
        outportSignalID.blkObj=blkObj;
        outportSignalID.pathItem='1';
        if~isempty(structSignalID.blkObj)&&~isempty(structSignalID.pathItem)
            sharedListPorts={outportSignalID,structSignalID};
            sharedLists{1}=sharedListPorts;
        end
        return;
    end




    if~strcmp(blkObj.Parent,bdroot(blkObj.Parent))

        return;
    end







    if hIsVirtualBus(h,hPorts.Inport(1))



        busInfo=get_param(hPorts.Inport(1),'SignalHierarchy');
        busAsVector=isempty(busInfo.BusObject);

        if busAsVector
            busAsVecSharedDTList=hShareSrcAtSamePort(h,blkObj);
            if~isempty(busAsVecSharedDTList)
                if length(busAsVecSharedDTList)==1
                    sharedLists{end+1}=busAsVecSharedDTList{1};
                end
            end
        end


    end
