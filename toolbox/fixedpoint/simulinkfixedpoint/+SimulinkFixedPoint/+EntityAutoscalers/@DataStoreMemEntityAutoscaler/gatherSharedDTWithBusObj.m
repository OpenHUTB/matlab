function sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)%#ok




    sharedLists={};

    listofblocks=blkObj.DSReadWriteBlocks;

    [busObjectHandle,~]=hGetResolvedBusObjHandle(h,blkObj,busObjHandleMap);

    if isempty(busObjectHandle)
        return;
    end


    for i=1:numel(listofblocks)
        mblkObj=get_param(listofblocks(i).name,'Object');
        DSList=getSharedDTForBusObjectEle(h,mblkObj,busObjectHandle,busObjHandleMap);
        sharedLists=h.hAppendToSharedLists(sharedLists,DSList);
    end


    function sharedLists=getSharedDTForBusObjectEle(h,blkObj,busObjHandle,busObjHandleMap)

        sharedLists={};

        if isa(blkObj,'Simulink.DataStoreWrite')
            isDSW=true;
        elseif isa(blkObj,'Simulink.DataStoreRead')
            isDSW=false;
        else


            return;
        end

        ph=blkObj.PortHandles;


        selectedSignalStr=blkObj.DataStoreElements;


        listOfSig=regexp(selectedSignalStr,'#','split');

        for listIdx=1:length(listOfSig)

            if isDSW
                portHandle=ph.Inport(listIdx);
            else
                portHandle=ph.Outport(listIdx);
            end

            if get_param(portHandle,'CompiledPortBusMode')==1

                continue;
            end

            busElementPath=listOfSig{listIdx};
            busObjEleID=h.hGetLeafBusObjElementID(busElementPath,busObjHandle,busObjHandleMap);



            if~isempty(busObjEleID)
                if isDSW
                    portObj=get_param(portHandle,'Object');
                    [srcSigID.blkObj,srcSigID.pathItem,srcSigID.srcInfo]=...
                    getSourceSignal(h,portObj,false);
                else
                    srcSigID.blkObj=blkObj;
                    srcSigID.pathItem=int2str(listIdx);
                end
                oneList={busObjEleID,srcSigID};
                sharedLists=h.hAppendToSharedLists(sharedLists,oneList);
            end
        end


