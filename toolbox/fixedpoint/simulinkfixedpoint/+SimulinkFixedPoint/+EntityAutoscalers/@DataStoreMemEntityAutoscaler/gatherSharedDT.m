function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};



    DTName=h.hCleanBusName(blkObj.OutDataTypeStr);
    DTName=h.hCleanBusName(DTName);
    [isBusName,~,~]=hGetBusNameThroughMask(h,DTName,blkObj);
    if isBusName
        return;
    end






    dataStoreRec.blkObj=blkObj;
    dataStoreRec.pathItem='1';



    listofblocks=blkObj.DSReadWriteBlocks;
    locList={};
    for i=1:numel(listofblocks)
        curStruct.blkObj=get_param(listofblocks(i).name,'Object');
        curStruct.pathItem='1';
        isDSMWrite=isa(curStruct.blkObj,'Simulink.DataStoreWrite');
        if~isDSMWrite&&~isa(curStruct.blkObj,'Simulink.DataStoreRead')

            continue;
        end
        if isDSMWrite

            upstreamlist=h.hShareDTSpecifiedPorts(curStruct.blkObj,1,[]);
            if~isempty(upstreamlist)
                locList(end+1)=upstreamlist;%#ok
            end
        end
        locList{end+1}=curStruct;%#ok    
    end

    if~isempty(locList)
        locList{end+1}=dataStoreRec;
    else
        locList{1}=dataStoreRec;
    end

    isResolved=strcmpi(blkObj.StateMustResolveToSignalObject,'on');

    if isResolved


        signalObject=slResolve(blkObj.DataStoreName,blkObj.getFullName);
        signalObjectName=blkObj.DataStoreName;
        sigRec.blkObj=SimulinkFixedPoint.SignalObjectWrapperCreator.getWrapper(...
        signalObject,signalObjectName,bdroot(blkObj.getFullName));
        sigRec.pathItem=signalObjectName;

        locList{end+1}=sigRec;
        sharedLists{1}=locList;
    elseif(numel(locList)>1)
        sharedLists{1}=locList;
    end


