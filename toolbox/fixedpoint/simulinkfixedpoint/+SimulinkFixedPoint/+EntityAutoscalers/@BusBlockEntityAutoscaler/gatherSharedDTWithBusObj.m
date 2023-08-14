function sharedLists=gatherSharedDTWithBusObj(h,blkObj,pathItem,busObjHandleMap)




    sharedLists={};


    if~strcmp(pathItem,'1')
        return;
    end

    if strcmp(blkObj.Virtual,'on')

        return;
    end

    ph=blkObj.PortHandles;
    inportHandle=ph.Inport(1);






    inputBusSigHier=get_param(inportHandle,'SignalHierarchy');


    selectedSignalStr=blkObj.OutputSignals;


    listOfOutput=regexp(selectedSignalStr,',','split');


    for outListIdx=1:length(listOfOutput)

        outportHandle=ph.Outport(outListIdx);


        if get_param(outportHandle,'CompiledPortBusMode')~=1
            busSignalName=listOfOutput{outListIdx};


            busObjID=hGetAssociatedBusObjElementForLeafSigName(h,inputBusSigHier,...
            busSignalName,busObjHandleMap);



            if~isempty(busObjID)
                srcSigID.blkObj=blkObj;
                srcSigID.pathItem=int2str(outListIdx);
                oneList={busObjID,srcSigID};
                sharedLists=h.hAppendToSharedLists(sharedLists,oneList);
            end
        end












    end


